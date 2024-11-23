#!/bin/bash

# Script to generate source files for Seoggi

# Create directories
mkdir -p src/core/{common,compiler/{ir,passes}}
mkdir -p src/runtime/{vm/{jit,stdlib},stdlib}
mkdir -p src/quantum/{circuit,gates,state,error,algorithms,optimization}
mkdir -p src/ai/{neural,quantum,training,models}
mkdir -p src/tests/{compiler,runtime/{vm,stdlib},quantum/{circuit,gates,algorithms},ai/{neural,quantum,training}}
mkdir -p src/tools/{compiler,runtime,doc,fmt,test,build,package}
mkdir -p build

# Touch all source files
# Core compiler
touch src/core/compiler/{lexer,parser,ast,codegen,error,type,symbol_table,scope,diagnostics,optimization}.seo
touch src/core/compiler/ir/{builder,module,function,basic_block,instruction,value,type}.seo
touch src/core/compiler/passes/{pass_manager,dead_code_elimination,constant_folding,inlining,loop_optimization}.seo

# Common utilities
touch src/core/common/{config,error,logger,utils,file_system,string_utils,memory,thread_pool,profiler,timer}.seo

# Runtime
touch src/runtime/vm/{interpreter,memory,scheduler,gc,stack,heap,frame,thread,object,class_loader,native_interface}.seo
touch src/runtime/vm/jit/{compiler,optimizer,cache}.seo
touch src/runtime/stdlib/{math,io,string,collections,system,time,network}.seo

# Quantum
touch src/quantum/circuit/{simulator,optimizer}.seo
touch src/quantum/gates/{basic,controlled,custom}.seo
touch src/quantum/state/{vector,density_matrix}.seo
touch src/quantum/error/{correction,mitigation}.seo
touch src/quantum/algorithms/{grover,shor,vqe,qaoa}.seo
touch src/quantum/optimization/{gradient,parameter}.seo

# AI/ML
touch src/ai/neural/{network,layers,optimizer,loss,activation,initializer,regularizer}.seo
touch src/ai/quantum/{qnn,hybrid,encoding,measurement}.seo
touch src/ai/training/{dataset,dataloader,trainer,validator}.seo
touch src/ai/models/{transformer,lstm,gru,attention}.seo

# Build system
touch build/{package,dependency,target,project,workspace,toolchain,platform,artifact,repository,cache}.seo

# Tests
touch src/tests/compiler/{lexer,parser,ast,codegen,type,optimization}_test.seo
touch src/tests/runtime/vm/{interpreter,memory,gc}_test.seo
touch src/tests/runtime/stdlib/math_test.seo
touch src/tests/quantum/circuit/simulator_test.seo
touch src/tests/quantum/gates/basic_test.seo
touch src/tests/quantum/algorithms/grover_test.seo
touch src/tests/ai/neural/network_test.seo
touch src/tests/ai/quantum/qnn_test.seo
touch src/tests/ai/training/trainer_test.seo
touch src/tests/build/{package,project}_test.seo

# Tools
touch src/tools/compiler/seoc.seo
touch src/tools/runtime/seorun.seo
touch src/tools/doc/seodoc.seo
touch src/tools/fmt/seofmt.seo
touch src/tools/test/seotest.seo
touch src/tools/build/seobuild.seo
touch src/tools/package/seopack.seo
