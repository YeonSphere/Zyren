#pragma once

#include <vector>
#include <memory>
#include "layers.h"
#include "optimizer.h"
#include "loss.h"

namespace seoggi {
namespace neural {

class Network {
public:
    Network();
    ~Network() = default;

    // Layer management
    void add_layer(std::unique_ptr<Layer> layer);
    void compile(std::unique_ptr<Optimizer> optimizer, std::unique_ptr<Loss> loss);
    
    // Training
    void train(const Matrix& inputs, const Matrix& targets, size_t epochs, size_t batch_size);
    Matrix predict(const Matrix& inputs) const;
    
    // Model state
    void save(const std::string& path) const;
    void load(const std::string& path);
    
    // Quantum integration
    void add_quantum_layer(std::unique_ptr<QuantumLayer> layer);
    void enable_quantum_optimization(bool enable = true);

private:
    std::vector<std::unique_ptr<Layer>> layers_;
    std::unique_ptr<Optimizer> optimizer_;
    std::unique_ptr<Loss> loss_;
    bool quantum_optimization_enabled_;
    
    // Forward and backward propagation
    Matrix forward(const Matrix& inputs) const;
    void backward(const Matrix& gradients);
    
    // Batch processing
    void process_batch(const Matrix& batch_inputs, const Matrix& batch_targets);
    
    // Helper functions
    void update_weights();
    void validate_architecture() const;
};

} // namespace neural
} // namespace seoggi
