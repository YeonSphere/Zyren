#include "network.h"
#include <stdexcept>
#include <fstream>
#include <algorithm>

namespace seoggi {
namespace neural {

Network::Network() : quantum_optimization_enabled_(false) {}

void Network::add_layer(std::unique_ptr<Layer> layer) {
    layers_.push_back(std::move(layer));
}

void Network::compile(std::unique_ptr<Optimizer> optimizer, std::unique_ptr<Loss> loss) {
    optimizer_ = std::move(optimizer);
    loss_ = std::move(loss);
    validate_architecture();
    
    // Initialize layers
    for (auto& layer : layers_) {
        layer->initialize();
    }
}

void Network::train(const Matrix& inputs, const Matrix& targets, size_t epochs, size_t batch_size) {
    if (inputs.rows() != targets.rows()) {
        throw std::invalid_argument("Input and target sizes don't match");
    }
    
    const size_t num_samples = inputs.rows();
    std::vector<size_t> indices(num_samples);
    std::iota(indices.begin(), indices.end(), 0);
    
    for (size_t epoch = 0; epoch < epochs; ++epoch) {
        // Shuffle training data
        std::random_shuffle(indices.begin(), indices.end());
        
        // Process mini-batches
        for (size_t i = 0; i < num_samples; i += batch_size) {
            const size_t current_batch_size = std::min(batch_size, num_samples - i);
            
            // Create batch matrices
            Matrix batch_inputs(current_batch_size, inputs.cols());
            Matrix batch_targets(current_batch_size, targets.cols());
            
            for (size_t j = 0; j < current_batch_size; ++j) {
                batch_inputs.row(j) = inputs.row(indices[i + j]);
                batch_targets.row(j) = targets.row(indices[i + j]);
            }
            
            process_batch(batch_inputs, batch_targets);
        }
    }
}

Matrix Network::predict(const Matrix& inputs) const {
    return forward(inputs);
}

void Network::save(const std::string& path) const {
    std::ofstream file(path, std::ios::binary);
    if (!file) {
        throw std::runtime_error("Failed to open file for saving");
    }
    
    // Save network architecture
    size_t num_layers = layers_.size();
    file.write(reinterpret_cast<const char*>(&num_layers), sizeof(num_layers));
    
    // Save each layer
    for (const auto& layer : layers_) {
        layer->save(file);
    }
}

void Network::load(const std::string& path) {
    std::ifstream file(path, std::ios::binary);
    if (!file) {
        throw std::runtime_error("Failed to open file for loading");
    }
    
    // Load network architecture
    size_t num_layers;
    file.read(reinterpret_cast<char*>(&num_layers), sizeof(num_layers));
    
    // Clear existing layers
    layers_.clear();
    
    // Load each layer
    for (size_t i = 0; i < num_layers; ++i) {
        auto layer = Layer::load(file);
        layers_.push_back(std::move(layer));
    }
}

void Network::add_quantum_layer(std::unique_ptr<QuantumLayer> layer) {
    layers_.push_back(std::move(layer));
}

void Network::enable_quantum_optimization(bool enable) {
    quantum_optimization_enabled_ = enable;
    if (enable) {
        for (auto& layer : layers_) {
            layer->enable_quantum_optimization();
        }
    }
}

Matrix Network::forward(const Matrix& inputs) const {
    Matrix current = inputs;
    for (const auto& layer : layers_) {
        current = layer->forward(current);
    }
    return current;
}

void Network::backward(const Matrix& gradients) {
    Matrix current_gradients = gradients;
    for (auto it = layers_.rbegin(); it != layers_.rend(); ++it) {
        current_gradients = (*it)->backward(current_gradients);
    }
}

void Network::process_batch(const Matrix& batch_inputs, const Matrix& batch_targets) {
    // Forward pass
    Matrix predictions = forward(batch_inputs);
    
    // Compute loss and gradients
    Matrix loss_gradients = loss_->gradient(predictions, batch_targets);
    
    // Backward pass
    backward(loss_gradients);
    
    // Update weights
    update_weights();
}

void Network::update_weights() {
    for (auto& layer : layers_) {
        optimizer_->update(*layer);
    }
}

void Network::validate_architecture() const {
    if (layers_.empty()) {
        throw std::runtime_error("Network has no layers");
    }
    
    // Validate layer connections
    for (size_t i = 1; i < layers_.size(); ++i) {
        if (!layers_[i]->is_compatible_with(*layers_[i-1])) {
            throw std::runtime_error("Incompatible layer dimensions");
        }
    }
}

} // namespace neural
} // namespace seoggi
