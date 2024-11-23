#include "circuit.h"
#include <cmath>
#include <stdexcept>
#include <iostream>

namespace seoggi {
namespace quantum {

Circuit::Circuit(size_t num_qubits) 
    : num_qubits_(num_qubits), 
      error_correction_enabled_(false) {
    initialize_statevector();
}

void Circuit::add_gate(std::unique_ptr<Gate> gate) {
    validate_qubit_index(gate->target());
    gates_.push_back(std::move(gate));
}

void Circuit::add_controlled_gate(std::unique_ptr<Gate> gate, size_t control, size_t target) {
    validate_qubit_index(control);
    validate_qubit_index(target);
    gate->set_control(control);
    gate->set_target(target);
    gates_.push_back(std::move(gate));
}

void Circuit::reset() {
    gates_.clear();
    initialize_statevector();
    measurements_.clear();
}

void Circuit::measure_all() {
    measurements_.resize(num_qubits_);
    for (size_t i = 0; i < num_qubits_; ++i) {
        // Collapse the quantum state based on measurement probabilities
        double prob_zero = std::norm(statevector_[i]);
        double random = static_cast<double>(rand()) / RAND_MAX;
        measurements_[i] = (random > prob_zero);
        
        // Update statevector after measurement
        size_t state_size = 1ULL << num_qubits_;
        for (size_t j = 0; j < state_size; ++j) {
            if ((j & (1ULL << i)) != (measurements_[i] ? 1ULL << i : 0)) {
                statevector_[j] = std::complex<double>(0, 0);
            }
        }
        
        // Normalize remaining amplitudes
        double norm = 0;
        for (const auto& amp : statevector_) {
            norm += std::norm(amp);
        }
        norm = std::sqrt(norm);
        
        for (auto& amp : statevector_) {
            amp /= norm;
        }
    }
}

std::vector<bool> Circuit::get_measurements() const {
    return measurements_;
}

void Circuit::hadamard(size_t qubit) {
    validate_qubit_index(qubit);
    auto gate = std::make_unique<HadamardGate>(qubit);
    add_gate(std::move(gate));
}

void Circuit::cnot(size_t control, size_t target) {
    validate_qubit_index(control);
    validate_qubit_index(target);
    auto gate = std::make_unique<CNOTGate>(control, target);
    add_gate(std::move(gate));
}

void Circuit::phase(size_t qubit, double angle) {
    validate_qubit_index(qubit);
    auto gate = std::make_unique<PhaseGate>(qubit, angle);
    add_gate(std::move(gate));
}

void Circuit::rx(size_t qubit, double angle) {
    validate_qubit_index(qubit);
    auto gate = std::make_unique<RXGate>(qubit, angle);
    add_gate(std::move(gate));
}

void Circuit::ry(size_t qubit, double angle) {
    validate_qubit_index(qubit);
    auto gate = std::make_unique<RYGate>(qubit, angle);
    add_gate(std::move(gate));
}

void Circuit::rz(size_t qubit, double angle) {
    validate_qubit_index(qubit);
    auto gate = std::make_unique<RZGate>(qubit, angle);
    add_gate(std::move(gate));
}

void Circuit::execute() {
    validate_circuit();
    initialize_statevector();
    
    for (const auto& gate : gates_) {
        apply_gate(*gate);
    }
}

std::vector<std::complex<double>> Circuit::get_statevector() const {
    return statevector_;
}

void Circuit::optimize() {
    // Implement circuit optimization techniques
    // - Gate cancellation
    // - Gate fusion
    // - Commutation rules
    // TODO: Implement optimization strategies
}

void Circuit::transpile() {
    // Convert circuit to hardware-specific gates
    // - Map to available native gates
    // - Handle connectivity constraints
    // TODO: Implement transpilation
}

void Circuit::enable_error_correction(bool enable) {
    error_correction_enabled_ = enable;
}

void Circuit::add_error_correction_code(const std::string& code_type) {
    if (!error_correction_enabled_) {
        throw std::runtime_error("Error correction is not enabled");
    }
    
    // Implement different error correction codes
    if (code_type == "bit-flip") {
        // Implement bit-flip code
    } else if (code_type == "phase-flip") {
        // Implement phase-flip code
    } else if (code_type == "shor") {
        // Implement Shor's 9-qubit code
    } else if (code_type == "steane") {
        // Implement Steane's 7-qubit code
    } else {
        throw std::invalid_argument("Unknown error correction code type");
    }
}

size_t Circuit::depth() const {
    // Calculate circuit depth (longest path through the circuit)
    // TODO: Implement depth calculation
    return gates_.size();
}

void Circuit::print() const {
    std::cout << "Quantum Circuit with " << num_qubits_ << " qubits:\n";
    for (size_t i = 0; i < num_qubits_; ++i) {
        std::cout << "q" << i << ": ";
        for (const auto& gate : gates_) {
            if (gate->target() == i) {
                std::cout << gate->name() << "--";
            } else if (gate->is_controlled() && gate->control() == i) {
                std::cout << "●--";
            } else {
                std::cout << "---";
            }
        }
        std::cout << "\n";
    }
}

void Circuit::initialize_statevector() {
    size_t state_size = 1ULL << num_qubits_;
    statevector_.resize(state_size);
    std::fill(statevector_.begin(), statevector_.end(), std::complex<double>(0, 0));
    statevector_[0] = std::complex<double>(1, 0);  // |0...0⟩ state
}

void Circuit::apply_gate(const Gate& gate) {
    gate.apply(statevector_, num_qubits_);
}

void Circuit::validate_qubit_index(size_t qubit) const {
    if (qubit >= num_qubits_) {
        throw std::out_of_range("Qubit index out of range");
    }
}

void Circuit::validate_circuit() const {
    if (gates_.empty()) {
        throw std::runtime_error("Circuit has no gates");
    }
    
    for (const auto& gate : gates_) {
        validate_qubit_index(gate->target());
        if (gate->is_controlled()) {
            validate_qubit_index(gate->control());
        }
    }
}

} // namespace quantum
} // namespace seoggi
