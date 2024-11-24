#pragma once

#include <vector>
#include <memory>

namespace seoggi {
namespace runtime {

class NeuralNetwork {
public:
    explicit NeuralNetwork(const std::vector<size_t>& layer_sizes);
    
    // Forward and backward propagation
    void forward(const std::vector<double>& input);
    void backward(const std::vector<double>& target);
    
    // Prediction and loss
    std::vector<double> predict(const std::vector<double>& input);
    double loss(const std::vector<double>& target);
    
private:
    std::vector<size_t> layer_sizes_;
    // TODO: Add weights, biases, and activations
};

} // namespace runtime
} // namespace seoggi
