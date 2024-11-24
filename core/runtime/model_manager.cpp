#include "model_manager.hpp"
#include <stdexcept>
#include <algorithm>
#include <fstream>

namespace seoggi {
namespace runtime {

ModelManager::ModelManager() 
    : max_models_(DEFAULT_MAX_MODELS) {
    // Initialize model management
}

ModelManager::ModelManager(size_t max_models) 
    : max_models_(max_models) {
    if (max_models == 0) {
        throw std::invalid_argument("Maximum number of models must be positive");
    }
}

std::shared_ptr<NeuralNetwork> ModelManager::create_model(const std::vector<size_t>& layer_sizes) {
    if (active_models_.size() >= max_models_) {
        throw std::runtime_error("Maximum number of active models reached");
    }
    
    auto model = std::make_shared<NeuralNetwork>(layer_sizes);
    active_models_.push_back(model);
    return model;
}

void ModelManager::release_model(const std::shared_ptr<NeuralNetwork>& model) {
    auto it = std::find(active_models_.begin(), active_models_.end(), model);
    if (it != active_models_.end()) {
        active_models_.erase(it);
    }
}

std::shared_ptr<NeuralNetwork> ModelManager::load_model(const std::string& filename) {
    if (active_models_.size() >= max_models_) {
        throw std::runtime_error("Maximum number of active models reached");
    }
    
    // TODO: Implement model loading
    throw std::runtime_error("Model loading not yet implemented");
}

void ModelManager::save_model(const std::shared_ptr<NeuralNetwork>& model, const std::string& filename) {
    // TODO: Implement model saving
    throw std::runtime_error("Model saving not yet implemented");
}

size_t ModelManager::active_model_count() const {
    return active_models_.size();
}

void ModelManager::set_max_models(size_t max_models) {
    if (max_models == 0) {
        throw std::invalid_argument("Maximum number of models must be positive");
    }
    max_models_ = max_models;
}

size_t ModelManager::get_max_models() const {
    return max_models_;
}

} // namespace runtime
} // namespace seoggi
