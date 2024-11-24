#pragma once

#include "neural_runtime.hpp"
#include <vector>
#include <memory>
#include <string>

namespace seoggi {
namespace runtime {

constexpr size_t DEFAULT_MAX_MODELS = 16;

class ModelManager {
public:
    ModelManager();
    explicit ModelManager(size_t max_models);
    
    // Model management
    std::shared_ptr<NeuralNetwork> create_model(const std::vector<size_t>& layer_sizes);
    void release_model(const std::shared_ptr<NeuralNetwork>& model);
    size_t active_model_count() const;
    
    // Model persistence
    std::shared_ptr<NeuralNetwork> load_model(const std::string& filename);
    void save_model(const std::shared_ptr<NeuralNetwork>& model, const std::string& filename);
    
    // Configuration
    void set_max_models(size_t max_models);
    size_t get_max_models() const;
    
private:
    size_t max_models_;
    std::vector<std::shared_ptr<NeuralNetwork>> active_models_;
};

} // namespace runtime
} // namespace seoggi
