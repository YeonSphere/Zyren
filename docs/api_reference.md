# Seoggi API Reference 
## Built-in Functions 
- `speak(message)`: Print a message to the console 
- `read(prompt)`: Read user input from the console 
- `to_number(value)`: Convert a value to a number 
- `to_string(value)`: Convert a value to a string 
- `length(collection)`: Return the length of a string, list, or dictionary 

## Modules 
### Web Module 
- `web.serve(handler, port=8080)`: Start a web server with the given request handler 
- `web.request(url, method="GET", data=null)`: Make an HTTP request to the specified URL 

### Database Module 
- `database.connect(type, path)`: Connect to a database of the specified type 
- `database.execute(query, *args)`: Execute a database query with optional arguments 
- `database.query(query, *args)`: Execute a database query and return the results 

## Control Structures 
### if-else Statement

## Additional Functions 
- `http_request(url, method, headers, body)`: Make HTTP requests
- `parse_json(json_string)`: Parse JSON data
- `create_window(title, width, height)`: Create a GUI window
- `train_model(data, model_type)`: Train an AI model
- `compile_to_native(source_code, target_platform)`: Compile Seoggi code to native code

## AI Utilities 
- `matrix_multiply(matrix1, matrix2)`: Multiply two matrices
- `gradient_descent(function, initial_params, learning_rate, iterations)`: Perform gradient descent optimization
- `neural_network(layers, activation_function)`: Create a neural network with specified layers and activation function
