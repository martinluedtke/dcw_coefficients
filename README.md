# dcw_coefficients
Computing the localization map in the Chabauty-Kim method for the S-unit equation

SAGE code for the paper "Refined Selmer equations for the thrice-punctured line in depth two" [BBKLMQSX]

Let $S$ be a finite set of primes and let $p$ be an auxiliary prime not contained in $S$. The Chabauty-Kim method is used to find functions on the 
$\mathbb{Z}\_p$-points of the thrice-punctured line which vanish on the $S$-integral points. To apply the method, it is central to understand the localization map in the Chabauty-Kim diagram. Dan-Cohen and Wewers [DCW] have shown that the localization map in depth two has the form

$$ \mathbb{A}^S \times \mathbb{A}^S \to \mathbb{A}^3 $$

with a bilinear form as its third component. For $l$ and $q$ in $S$ we denote by $a_{l,q}$ the coefficient of $x_l y_q$ and refer to it as a "Dan-Cohen--Wewers (DCW) coefficient". It is an element of 
$\mathbb{Q}\_p$ and depends only on $l$ and $q$ (not on $S$).

The DCW coefficients can be determined as follows. Let 

$$ E := \mathbb{Q} \otimes \mathbb{Z}\_{(p)}^\times. $$

This is an infinite-dimensional 
$\mathbb{Q}$-vector space with basis $1 \otimes l$ for $l$ a prime different from $p$. For 
$a \in \mathbb{Z}\_{(p)}^\times$, write $[a] := 1 \otimes a \in E$. 
An element of the form $[t] \wedge [1-t]$ with $t, 1-t \in \mathbb{Z}\_{(p)}^\times$ 
in the wedge square $E \wedge E$ is called a "Steinberg element". Every element of $E \wedge E$ can be written as a 
$\mathbb{Q}$-
linear combination of Steinberg elements. Assume that we have such an expression for $[l] \wedge [q]$:

$$ [l] \wedge [q] = \sum c_i [t_i] \wedge [1-t_i]. $$

Then we have the following formula for the DCW coefficient $a_{l,q}$:

$$ a_{l,q} = 1/2 (\sum_i c_i (-\mathrm{Li}\_2(t_i)+\mathrm{Li}\_2(1-t_i)) + \log(l)\log(q)), $$

where $\log$ and 
$\mathrm{Li}\_2$ 
denote the $p$-adic logarithm and dilogarithm, respectively.

## 1. Computing Steinberg decompositions
We implement an algorithm to compute expressions for $[l] \wedge [q]$ as 
$\mathbb{Q}$-
linear combinations of Steinberg elements. The function `steinberg_decompositions(bound, p)` returns a dict `{(l,q): dec}` where `dec` is a decomposition of $[l] \wedge [q]$. The decomposition is encoded as a dict `{t_i: c_i}` where 
$c\_i$ 
is the coefficient of the Steinberg element 
$[t\_i] \wedge [1-t\_i]$.

### Example
Computing the decompositions of $[l] \wedge [q]$ with $l,q < 10$ for $p = 3$:
```sage
sage: steinbergs, decompositions = steinberg_decompositions(bound=10, p=3)
sage: decompositions[2,5]
{-4: 1/2}
sage: decompositions[5,7]
{-4: -1/2, -5/2: 1, 1/8: -1/3}
```
This tells us that $[2] \wedge [5] = 1/2 [-4]\wedge [5]$ and 

$$ [5] \wedge [7] = -1/2 [-4] \wedge [5] - [-5/2] \wedge [7/2] - 1/3 [1/8] \wedge [7/8].$$


Observe that none of the numbers contains factors of $p=3$.

## 2. Computing approximations of DCW coefficients

Using Steinberg decompositions, we can compute p-adic approximations of the DCW coefficients. The function `dcw_coefficients(bound, p, decompositions, prec)` returns a dict `{(l,q}: a}` where a is a p-adic rational number approximating the DCW coefficient $a_{l,q}$. The function uses SAGE's built-in log and dilog functions. The parameter "prec" is the internal precision with which p-adic numbers are represented.

### Example
```sage
sage: bound = 10
sage: p = 3
sage: steinbergs, decompositions = steinberg_decompositions(bound, p)
sage: dcw_coeffs = dcw_coefficients(bound, p, decompositions, prec=12)
sage: dcw_coeffs[2,5]
3^2 + 2*3^4 + 2*3^5 + 2*3^6 + O(3^7)
```

For the prime $p = 3$ we have a tailor-made function `three_adic_dcw_coefficients` which calculates the DCW coefficients more efficiently and with guaranteed precision:
```sage 
sage: bound = 10
sage: prec = 12
sage: steinbergs, decompositions = steinberg_decompositions(bound, 3)
sage: dcw_coeffs = three_adic_dcw_coefficients(bound, decompositions, prec)
sage: dcw_coeffs[2,5]
428580
sage: Qp(3,prec=prec)(dcw_coeffs[2,5])
3^2 + 2*3^4 + 2*3^5 + 2*3^6 + 2*3^8 + 3^10 + 2*3^11 + O(3^14)
```
The result is a rational number which is guaranteed to be a correct approximation of $a_{l,q}$ up to O(3^prec). Note how the result in the example is more precise than with the function `steinberg_decompositions`.

## 3. Determining the size of Chabauty-Kim sets
Let $S = \\{l,q\\}$ be a set of two primes which are both different from 3. The $S$-integral points of the thrice-punctured line carry an $S_3$-action generated by $z \mapsto 1-z$ and $z \mapsto 1/z$. In [BBKLMQSX] we show that each $S$-integral point has an $S_3$-translate which satisfies the refined  Selmer equation

$$ a\_{l,q} \mathrm{Li}\_2(z) = a_{q,l} \mathrm{Li}_2(1-z). $$

The "refined Chabauty-Kim set" for $S$ in depth two for the auxiliary prime $p = 3$ consists of the $S_3$-orbits of all 
$\mathbb{Z}\_3$-
points of the thrice-punctured line satisfying this equation. We show that the refined Chabauty-Kim set contains the $S\_3$-orbit 
$\\{2,-1,1/2\\}$ 
and at most one additional orbit. The additional orbit is present if and only if the valuations of the DCW coefficients satisfy

$$ \min(v_3(a_{l,q}), v_3(a_{q,l})) = v_3(\log(l)) + v_3(\log(q)). $$


The function `check_extrapoint_criterion` determines all pairs of primes $l$, $q$ below a given bound where this condition is satisfied.

### Example
```sage
sage: extrapoint, noextrapoint, undecided = check_extrapoint_criterion(bound=20, prec=12)
sage: extrapoint
[(2, 5), (2, 7), (5, 7), (2, 11), (5, 11), (7, 11), (2, 13), (5, 13), (7, 13), (11, 13), (2, 17), (5, 17), (11, 17), (7, 19)]
sage: noextrapoint
[(7, 17), (13, 17), (2, 19), (5, 19), (11, 19), (13, 19), (17, 19)]
sage: undecided
[]
```
This tells us for example that the refined Chabauty-Kim set in depth 2 for 
$S = \\{2,5\\}$
and $p = 3$ contains an additional $S\_3$-orbit of points besides 
$\\{2,-1,1/2\\}$,
whereas it does not for 
$S = \\{2,19\\}$.
In particular, the set cut out by the refined Selmer equation for 
$S = \\{2,19\\}$
coincides, up to $S_3$-orbits, exactly with the solutions of the 
$\\{2,19\\}$-unit equation.

The results for the bound 500 (which are computed in under 10 minutes) are contained in the file `extrapoint500.txt`.

See the comments in the SAGE code for more examples.

## References

- [BBKLMQSX] Alex Best, L. Alexander Betts, Theresa Kumpitsch, Martin Lüdtke, Angus William McAndrew, Lie Qian, Elie Studnia, and Yujie Xu, "Refined Selmer equations for the thrice-punctured line in depth two" (2021)
  
- [DCW] Ishai Dan-Cohen and Stefan Wewers, "Explicit Chabauty–Kim theory for the thrice punctured line in depth 2" (2015)
  
## Authors

- Theresa Kumpitsch
- Martin Lüdtke
- Elie Studnia
