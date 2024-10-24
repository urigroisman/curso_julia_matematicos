"""
# Unidad 2
## Repaso básico
"""

# Hello World!
println("There is more than one way to say hello:")

# This is an array consisting of three strings
helloArray = ["Hello","G'day","Shalom"]

for i in 1:3
    println("\t", helloArray[i], " World!")
end

println("\nThese squares are just perfect:")

# This construct is called a 'comprehension' (or 'list comprehension')
squares = [i^2 for i in 0:10]

# You can loop on elements of arrays without having to use indexing
for s in squares
    print("  ",s)
end
println()

# The last line of every code snippet is also evaluated as output (in addition to
# any figures and printing output generated previously).
sqrt.(squares)

"""

#Square root (the 1'st story)

*Basics
*Variables (also complex types)
*Types (basic story about types)
*Many methods for the one function
*The Babylonian algorithm
*Broadcasting as well
*The "quakeIII" algorithm for the reciprocal of square root Float32

"""

# Uso estandar
sqrt(25) # devuelve un Float64 (sería lindo un valor exacto)

# Float64 y Float32
x = sqrt(2)
@show x, x^2

y = sqrt(2f0) # 32 bits Float, Float32
@show y, y^2 # 2f0^2 no me da 4 trabajando con 32 bits

√-1 # la raiz de un negativo, no le gusta...
√Complex(-1) # todo tiene arreglo
typeof(√Complex(-1))

# En julia una función puede tener muchos métodos (multi dispatch)
using InteractiveUtils
@which sqrt(2)
@which sqrt(2.0)
@which sqrt(π*im)

"""
 Y si quisiermos calcular una raiz cuadrada y no tuviésemos la funcion sqrt()?, 
 bueno podríamos usar otra función in-built
"""
 x = 36
@show x^0.5 # lindo truco



"""
¿Cómo está instrumentada la función sqrt() en julia.  lo podemos ver en 
https://github.com/JuliaLang/julia/blob/master/base/math.jl en las lineas 566-569


```Julia 

    @inline function sqrt(x::Union{Float32,Float64})
        x < zero(x) && throw_complex_domainerror(:sqrt, x)
        sqrt_llvm(x)
    end

```

Aquí sqrt_llvm() se compila a Low Level Virtual Machine (LLVM), por lo que, aunque muchas 
funciones en Julia están realmente implementadas en Julia, con las raíces cuadradas es mejor dejar 
que el código subyacente de bajo nivel (LLVM) se encargue de las raíces cuadradas porque 
posteriormente se transforma en código ensamblador, el cual es muy rápido. 
Puedes inspeccionar esto a través de los macros @code_llvm y @code_native.

Esto generalmente se verá igual en diferentes tipos de computadoras (LLVM es independiente del hardware).
"""

@code_llvm sqrt(2.5)    # este macro muestra en el REPL el código LLVM de la raiz de 2.5 y es una demostración 
                        # contundente del porqué programamos en lenguajes de alto nivel, INDEPENDENTE MAQUINA

@code_native sqrt(2.5)  # muestra código de máquina (assembly) específico para el OS y el CPU de la nuestra



"""
There are several methods to compute square roots, each with its own principles and implementation 
characteristics. Let's explore a few of them, starting with the Babylonian method.

1. Babylonian (or Heron's) Algorithm:
The Babylonian algorithm is an ancient iterative method for approximating square roots. It works by 
repeatedly averaging an initial guess with the quotient of the target number and the guess.

Given a number z for which we want to compute the square root, the iterative formula is:

x_(k+1)=frac{1}{2}(x_k+frac{z}{x_k}

That is, at each step the next iterate is the arithmetic mean of the previous iterate, xk, and z/xk.
The Babylonian algorithm runs this iteration until convergence 
(note the default initial guess in this implementation is z/2):

"""

function bab_sqrt(z ; init_x = z/2, verbose = false, tol = 1e-10) # interesante forma del input a la función
    x = init_x
    while true # loop se mantiene hasta que se alcance la tolerancia requerida en tol
        verbose && println("Babylonian iterate: $x")
        next_x = 0.5*(x + z / x)
        abs(next_x - x) < tol && break
        x = next_x
    end
    x
end

@time bs, s = bab_sqrt(587549; verbose = true), @time sqrt(587549) 
println("Babylonian:\t$bs\nSystem:\t\t$s")

#=
We can view the ancient Babylonian method as an application of the more general Newton's method for solving equations. Our goal is to solve \(x^2 = z\) where \(z\) is given and \(x\) is desired. That is, define \(f(x) = x^2 - z\) and we wish to find the solution of \(f(x) = 0\). Newton's method iterates,

\[
x_{k+1} = x_k - \frac{f(x_k)}{f'(x_k)},
\]

based on an affine (linear) approximation of \(f(\cdot)\) at the point \(x_k\). Here \(f'(\cdot)\) is the derivative, which in our case is \(f'(x) = 2x\). So Newton's iterates for finding the square root are,

\[
x_{k+1} = x_k - \frac{x_k^2 - z}{2x_k} = \frac{x_k}{2} + \frac{z}{2x_k} = \frac{1}{2} \left(x_k + \frac{z}{x_k}\right).
\]
=#

"""
Sometimes we are not just interested in computing the \(\sqrt{z}\), but rather,

\[
\frac{1}{\sqrt{z}}.
\]

A common case for that is when we have a vector, say \(u = [u_1, u_2]\) and we wish to create 
the normalized (unit \(L_2\) norm) vector,

\[
\hat{u} = \frac{1}{\|u\|} u = \frac{1}{\sqrt{u_1^2 + u_2^2}} u.
\]

We could obviously just compute the reciprocal \(1/\sqrt{z}\) by dividing by 1, for example, 
in the case of the vector normalization, we can do this in Julia in multiple ways:
"""

using LinearAlgebra
using BenchmarkTools
u = ones(1000000,1) #A vector pointing in a 45 degree angle up.

@btime uN1 = normalize(u) #Julia has a function for this in linear algebra.
#@show uN1

@btime uN2 = u/norm(u) #Here we do it via the norm() function
#@show uN2

@btime uN3 = u/sqrt(u'u) # Note that u'u = u_1^2 + u_2^2 (the inner product)
#@show uN3

@btime uN4 = u/sqrt(u[1]^2 + u[2]^2)
#@show uN4

@btime uN5 = u/sqrt(dot(u,u))
#@show uN5;