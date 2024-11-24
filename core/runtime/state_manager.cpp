#include "state_manager.hpp"
#include <stdexcept>
#include <algorithm>

namespace seoggi {
namespace runtime {

StateManager::StateManager() 
    : max_qubits_(DEFAULT_MAX_QUBITS) {
    // Initialize state management
}

StateManager::StateManager(size_t max_qubits) 
    : max_qubits_(max_qubits) {
    if (max_qubits == 0) {
        throw std::invalid_argument("Maximum number of qubits must be positive");
    }
}

std::shared_ptr<QuantumState> StateManager::create_state(size_t num_qubits) {
    if (num_qubits > max_qubits_) {
        throw std::out_of_range("Requested number of qubits exceeds maximum");
    }
    
    auto state = std::make_shared<QuantumState>(num_qubits);
    active_states_.push_back(state);
    return state;
}

void StateManager::release_state(const std::shared_ptr<QuantumState>& state) {
    auto it = std::find(active_states_.begin(), active_states_.end(), state);
    if (it != active_states_.end()) {
        active_states_.erase(it);
    }
}

size_t StateManager::active_state_count() const {
    return active_states_.size();
}

void StateManager::set_max_qubits(size_t max_qubits) {
    if (max_qubits == 0) {
        throw std::invalid_argument("Maximum number of qubits must be positive");
    }
    max_qubits_ = max_qubits;
}

size_t StateManager::get_max_qubits() const {
    return max_qubits_;
}

} // namespace runtime
} // namespace seoggi
