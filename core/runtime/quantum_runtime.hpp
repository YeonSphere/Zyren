#pragma once

#include <vector>
#include <complex>
#include <memory>

namespace seoggi {
namespace runtime {

class QuantumState {
public:
    explicit QuantumState(size_t num_qubits);
    
    // Basic quantum gates
    void hadamard(size_t qubit);
    void cnot(size_t control, size_t target);
    void phase(size_t qubit, double angle);
    
    // Measurement
    std::vector<bool> measure();
    
private:
    size_t num_qubits_;
    // TODO: Add quantum state representation
};

} // namespace runtime
} // namespace seoggi
