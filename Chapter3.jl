# Chapter3.jl

# 3.3.1 A simple self-attention mechanism without trainable weights

# import torch
# inputs = torch.tensor(
#   [[0.43, 0.15, 0.89], # Your     (x^1)
#    [0.55, 0.87, 0.66], # journey  (x^2)
#    [0.57, 0.85, 0.64], # starts   (x^3)
#    [0.22, 0.58, 0.33], # with     (x^4)
#    [0.77, 0.25, 0.10], # one      (x^5)
#    [0.05, 0.80, 0.55]] # step     (x^6)
# ) 

using LinearAlgebra


# Contrast with row-major languages: In a row-major language like Python (NumPy), matrices are stored row-by-row. Accessing elements row-by-row in such languages is more efficient due to contiguous memory storage in that order.

# Thus, being aware of Julia's column-major nature can be useful for optimizing code, especially for large-scale computations involving arrays and matrices.
# inputs = [
#     0.43 0.15 0.89;  # Your     (x^1)
#     0.55 0.87 0.66;  # journey  (x^2)
#     0.57 0.85 0.64;  # starts   (x^3)
#     0.22 0.58 0.33;  # with     (x^4)
#     0.77 0.25 0.10;  # one      (x^5)
#     0.05 0.80 0.55  # step     (x^6)
# ]

inputs = [0.43 0.55 0.57 0.22 0.77 0.05;
    0.15 0.87 0.85 0.58 0.25 0.8;
    0.89 0.66 0.64 0.33 0.1 0.55]
# Your   journey starts with  one   step

# query = inputs[1] 
# attn_scores_2 = torch.empty(inputs.shape[0])

query = inputs[:, 2]
attn_scores_2 = zeros(size(inputs, 2))

# for i, x_i in enumerate(inputs):
#     attn_scores_2[i] = torch.dot(x_i, query)

# Computing the dot product
for (i, _) in enumerate(eachcol(inputs))
    attn_scores_2[i] = dot(inputs[:, i], query)
end

# print(attn_scores_2)
println("Attention Scores without normalization: ", attn_scores_2)

# Understanding the dot product section
# res = 0
# ## without torch.dot
# for idx, element in enumerate(inputs[0]):
#     res += inputs[0][idx] * query[idx]
# print(res)

# Understanding the dot product section
res = 0.0
# Dot product without dot function
for idx in 1:length(inputs[1])
    res += inputs[1][idx] * query[idx]
end
println(res)

# with torch.dot
# print(torch.dot(inputs[0], query))
# with LinearAlgebra's dot() function
println("Dot product with dot function: ", dot(inputs[1], query))

# normalization step (version 1)

# attn_weights_2_tmp = attn_scores_2 / attn_scores_2.sum()
# print("Attention weights:", attn_weights_2_tmp)
# print("Sum:", attn_weights_2_tmp.sum())

attn_weights_2_tmp = attn_scores_2 ./ sum(attn_scores_2)
println("Attention weights (normalized): ", attn_weights_2_tmp)
println("Sum of weights: ", sum(attn_weights_2_tmp))

# Softmax normalization

## with native python
# def softmax_naive(x):
#     return torch.exp(x) / torch.exp(x).sum(dim=0)

# attn_weights_2_naive = softmax_naive(attn_scores_2)
# print("Attention weights:", attn_weights_2_naive)
# print("Sum:", attn_weights_2_naive.sum())

# ## with pytorch's softmax function
# attn_weights_2 = torch.softmax(attn_scores_2, dim=0)
# print("Attention weights:", attn_weights_2)
# print("Sum:", attn_weights_2.sum())

function softmax_naive(x)
    exp_x = exp.(x)
    return exp_x ./ sum(exp_x)
end

attn_weights_2_naive = softmax_naive(attn_scores_2)
println("Attention weights (softmax naive): ", attn_weights_2_naive)
println("Sum of weights (softmax naive): ", sum(attn_weights_2_naive))

# Using Julia's built-in softmax
using Flux
attn_weights_2 = softmax(attn_scores_2)
println("Attention weights (softmax function): ", attn_weights_2)
println("Sum of weights (softmax function): ", sum(attn_weights_2))

## summing the resulting vectors
# query = inputs[1]         #1
# context_vec_2 = torch.zeros(query.shape)
# for i,x_i in enumerate(inputs):
#     context_vec_2 += attn_weights_2[i]*x_i
# print(context_vec_2)

context_vec_2 = zeros(length(query))
for (i, col) in enumerate(eachcol(inputs))
    context_vec_2 .+= attn_weights_2[i] .* col
end
println("Context vector: ", context_vec_2)