#pragma once

#include "quantum_runtime.hpp"
#include <vector>
#include <memory>

namespace seoggi {
namespace runtime {

constexpr size_t DEFAULT_MAX_QUBITS = 32;

class StateManager {
public:
    StateManager();
    explicit StateManager(size_t max_qubits);
    
    // State management
    std::shared_ptr<QuantumState> create_state(size_t num_qubits);
    void release_state(const std::shared_ptr<QuantumState>& state);
    size_t active_state_count() const;
    
    // Configuration
    void set_max_qubits(size_t max_qubits);
    size_t get_max_qubits() const;
    
private:
    size_t max_qubits_;
    std::vector<std::shared_ptr<QuantumState>> active_states_;
};

} // namespace runtime
} // namespace seoggi
