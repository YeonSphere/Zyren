#pragma once

#include <vector>
#include <complex>
#include <memory>
#include "gates.h"

namespace seoggi {
namespace quantum {

class Circuit {
public:
    Circuit(size_t num_qubits);
    ~Circuit() = default;

    // Gate operations
    void add_gate(std::unique_ptr<Gate> gate);
    void add_controlled_gate(std::unique_ptr<Gate> gate, size_t control, size_t target);
    
    // State manipulation
    void reset();
    void measure_all();
    std::vector<bool> get_measurements() const;
    
    // Quantum operations
    void hadamard(size_t qubit);
    void cnot(size_t control, size_t target);
    void phase(size_t qubit, double angle);
    void rx(size_t qubit, double angle);
    void ry(size_t qubit, double angle);
    void rz(size_t qubit, double angle);
    
    // Circuit execution
    void execute();
    std::vector<std::complex<double>> get_statevector() const;
    
    // Circuit optimization
    void optimize();
    void transpile();
    
    // Quantum error correction
    void enable_error_correction(bool enable = true);
    void add_error_correction_code(const std::string& code_type);
    
    // Utility functions
    size_t num_qubits() const { return num_qubits_; }
    size_t depth() const;
    void print() const;

private:
    size_t num_qubits_;
    std::vector<std::unique_ptr<Gate>> gates_;
    std::vector<std::complex<double>> statevector_;
    std::vector<bool> measurements_;
    bool error_correction_enabled_;
    
    // Helper functions
    void initialize_statevector();
    void apply_gate(const Gate& gate);
    void validate_qubit_index(size_t qubit) const;
    void validate_circuit() const;
};

} // namespace quantum
} // namespace seoggi
