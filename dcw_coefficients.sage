r"""
DCW Coefficients

SAGE code for the paper "Refined Selmer equations for the thrice-punctured
line in depth two" [BBKLMQSX].

Let $S$ be a finite set of primes and let $p$ be an auxiliary prime not
contained in $S$. The Chabauty-Kim method is used to find functions on the
$\mathbb{Z}_p$-points of the thrice-punctured line which vanish on the
$S$-integral points. To apply the method, it is central to understand the
localization map in the Chabauty-Kim diagram. Dan-Cohen and Wewers [DCW]
have shown that the localization map in depth two has the form

    $\mathbb{A}^S \times \mathbb{A}^S \to \mathbb{A}^3$

with a bilinear form as its third component. For $l$ and $q$ in $S$ we denote
by $a_{l,q}$ the coefficient of $x_l y_q$ and refer to it as a
"Dan-Cohen--Wewers (DCW) coefficient". It is an element of $\mathbb{Q}_p$
and depends only on $l$ and $q$ (not on $S$).

The DCW coefficients can be determined as follows.
Let $E := \mathbb{Q} \otimes \mathbb{Z}_{(p)}^\times$. This is an infinite-
dimensional $\mathbb{Q}$-vector space with basis $1 \otimes l$ for $l$ a prime
different from $p$. For $a \in \mathbb{Z}_{(p)}^\times$, write
$[a] := 1 \otimes a \in E$. An element of the form $[t] \wedge [1-t]$ with
$t, 1-t \in \mathbb{Z}_{(p)}^\times$ in the wedge square $E \wedge E$ is
called a "Steinberg element". Every element of $E \wedge E$ can be written
as a $\mathbb{Q}$-linear combination of Steinberg elements. Assume that we have
such an expression for $[l] \wedge [q]$:

    $[l] \wedge [q] = \sum c_i [t_i] \wedge [1-t_i]$.

Then we have the following formula for the DCW coefficient $a_{l,q}$:

    $a_{l,q} = 1/2 (\sum_i c_i (-\Li_2(t_i)+\Li_2(1-t_i)) + \log(l)\log(q))$,

where $\log$ and $\Li_2$ denote the $p$-adic logarithm and dilogarithm,
respectively.


1. Computing Steinberg decompositions
=====================================

We implement an algorithm to compute expressions for $[l] \wedge [q]$
as $\mathbb{Q}$-linear combinations of Steinberg elements. The function
"steinberg_decompositions(bound, p)" returns a dict {(l,q): dec} where
dec is a decomposition of $[l] \wedge [q]$. The decomposition is encoded
as a dict {t_i: c_i} where c_i is the coefficient of the Steinberg element
$[t_i] \wedge [1-t_i]$.

Example
-------

Computing the decompositions of $[l] \wedge [q]$ with $l,q < 10$ for $p = 3$:

    sage: steinbergs, decompositions = steinberg_decompositions(bound=10, p=3)
    sage: decompositions[2,5]
    {-4: 1/2}
    sage: decompositions[5,7]
    {-5/2: 1, 1/8: -1/3, -4: -1/2}

This tells us that $[2] \wedge [5] = 1/2 [-4] \wedge [5]$ and
$[5] \wedge [7] = [-5/2] \wedge [7/2] - 1/2 [-4] \wedge  [5]$.
Observe that none of the numbers contains factors of $p=3$.



2. Computing approximations of DCW coefficients
===============================================

Using Steinberg decompositions, we can compute p-adic approximations of the
DCW coefficients. The function "dcw_coefficients(bound, p, decompositions, prec)"
returns a dict ``{(l,q}: a}`` where a is a p-adic rational number approximating
the DCW coefficient $a_{l,q}$. The function uses SAGE's built-in log and dilog
functions. The parameter "prec" is the internal precision with which p-adic numbers
are represented.


Example
-------

    sage: bound = 10
    sage: p = 3
    sage: steinbergs, decompositions = steinberg_decompositions(bound, p)
    sage: dcw_coeffs = dcw_coefficients(bound, p, decompositions, prec=12)
    sage: dcw_coeffs[2,5]
    3^2 + 2*3^4 + 2*3^5 + 2*3^6 + O(3^7)


For the prime $p = 3$ we have a tailor-made function "three_adic_dcw_coefficients"
which calculates the DCW coefficients more efficiently and with guaranteed precision:

    sage: bound = 10
    sage: prec = 12
    sage: steinbergs, decompositions = steinberg_decompositions(bound, 3)
    sage: dcw_coeffs = three_adic_dcw_coefficients(bound, decompositions, prec)
    sage: dcw_coeffs[2,5]
    428580
    sage: Qp(3,prec=prec)(dcw_coeffs[2,5])
    3^2 + 2*3^4 + 2*3^5 + 2*3^6 + 2*3^8 + 3^10 + 2*3^11 + O(3^14)

The result is a rational number which is guaranteed to be a correct approximation
of a_{l,q} up to O(3^prec). Note how the result in the example is more precise
than with the function "steinberg_decompositions".


3. Determining the size of Chabauty-Kim sets
============================================

Let $S = \{2,q\}$ with $q > 3$ a prime. The $S$-integral points of the
thrice-punctured line carry an $S_3$-action generated by $z \mapsto 1-z$ and
$z \mapsto 1/z$. In [BBKLMQSX] we show that each $S$-integral point has an
$S_3$-translate which satisfies the refined Selmer equation

	$a_{2,q} \Li_2(z) = a_{q,2} = \Li_2(1-z)$.

The "refined Chabauty-Kim set" for $S$ in depth two for the auxiliary prime $p = 3$
consists of the $S_3$-orbits of all $\mathbb{Z}_3$-points of the thrice-punctured
line satisfying this equation. We show that the refined Chabauty-Kim set contains
the $S_3$-orbit $\{2,-1,1/2\}$ and at most one additional orbit. The additional
orbit is present if and only if the valuations of the DCW coefficients satisfy

	$\min(v_3(a_{2,q}, a_{q,2}) = 1 + v_3(\log(q))$.

The function "check_extrapoint_criterion" determines the primes $q > 3$
below a given bound where this condition is satisfied.

EXAMPLE:

    sage: extrapoint, noextrapoint, undecided = check_extrapoint_criterion(bound=20, prec=12)
    sage: extrapoint
    [5, 7, 11, 13, 17]
    sage: noextrapoint
    [19]
    sage: undecided
    []

This tells us for example that the refined Chabauty-Kim set in depth 2 for
$S = \{2,5\}$ and $p = 3$ contains an additional $S_3$-orbit of points besides
$\{2,-1,1/2\}$, whereas it does not for $S = \{2,19\}$. In particular, the set
cut out by the refined Selmer equation for $S = \{2,19\}$ coincides, up to
$S_3$-orbits, exactly with the solutions of the $\{2,19\}$-unit equation.




REFERENCES:

- [BBKLMQSX] Alex Best, L. Alexander Betts, Theresa Kumpitsch, Martin Lüdtke,
  Angus William McAndrew, Lie Qian, Elie Studnia, and Yujie Xu, "Refined Selmer
  equations for the thrice-punctured line in depth two" (v2, 2022)

- [DCW] Ishai Dan-Cohen and Stefan Wewers, "Explicit Chabauty–Kim theory for the
  thrice punctured line in depth 2" (2015)


AUTHORS:

- Theresa Kumpitsch
- Martin Lüdtke
- Elie Studnia

"""


def steinberg_decompositions(bound, p):
    r"""
    Compute a Steinberg basis for the subspace of $E \wedge E$ generated by
    $[l] \wedge [q]$ with primes $l < q < bound$ and $l,q \neq p$, and express
    these prime generators in terms of the Steinberg basis.

    INPUT:

    - ``bound`` -- upper bound for subspace generators [l] \wedge [q]

    - ``p`` -- odd auxiliary prime

    OUTPUT:

    - ``steinberg_basis`` -- list of t_i s.t. the Steinberg elements
       $[t_i] \wedge [1-t_i]$ form a basis

    - ``decompositions`` -- dict ``{ (l,q) : dec }`` containing decompositions of
      the $[l] \wedge [q]$ as Q-linear combinations of the Steinberg elements.
      Each decomposition is encoded as a dict ``{ t_i : c_i }`` where $c_i$ is the
      coefficient of $[t_i] \wedge [1-t_i]$.

    EXAMPLES:

        Computing decompositions of $[l] \wedge [q]$ with $l,q < 20$ for p = 3:

            sage: steinbergs, decompositions = steinberg_decompositions(bound=20, p=3)
            sage: decompositions[7,11]
            {-10: 2/5, -4: 4/5, -7/4: 1, 1/8: 2/3, 5/16: -2/5}

	Thus, $[7] \wedge [11] = 2/5 [-10]\wedge[11] + [-7/4]\wedge[11/4] - 2/5 [5/16]\wedge[11/16]$.
	Note how none of the numbers contains factors of three. For $p = 5$ we
	get a different result which avoids factors of 5:

	    sage: steinbergs, decompositions = steinberg_decompositions(bound=20, p=5)
            sage: decompositions[7,11]
            {-6: -5/3, -9/2: 7/5, -3/4: -1/3, -1/2: -4/15, -3/8: -4/5, 7/18: 1}

    """

    prime_list = [l for l in primes(bound) if l != p]
    steinberg_basis = [] # basis of Steinberg elements [t] \wedge [1-t] with t and 1-t not containing factors of p
    dimension = (len(prime_list)*(len(prime_list) - 1))//2
    A = matrix(QQ, dimension) # matrix to change from prime basis to Steinberg basis

    old_dim = 0
    for iq in range(len(prime_list)):
        q = prime_list[iq]
        # matrix A^{-1} to change Steinberg basis to prime basis is extended to the right by block matrix [[U],[V]]
        dim_increase = iq
        U = matrix(QQ, old_dim, dim_increase)
        V = matrix(QQ, dim_increase)
        lin_indep_steinbergs = []
        for il in range(iq):
            if len(lin_indep_steinbergs) == dim_increase:
                break
            l = prime_list[il]
            for t in modified_dcw(l, q, p):
                # calculate new column of V
                t_factored = False
                one_minus_t_factored = False
                if t.denom() % q == 0 or t.numerator() % q == 0:
                    one_minus_t_factorisation = list(factorisation(1-t, prime_list))
                    one_minus_t_factored = True
                    for (i_pb, eb) in one_minus_t_factorisation:
                        if i_pb != iq:
                            V[i_pb,len(lin_indep_steinbergs)] -= t.valuation(q)*eb
                if (1-t).denom() % q == 0 or (1-t).numerator() % q == 0:
                    t_factorisation = list(factorisation(t, prime_list))
                    t_factored = True
                    for (i_pa, ea) in t_factorisation:
                        if i_pa != iq:
                            V[i_pa,len(lin_indep_steinbergs)] += ea*(1-t).valuation(q)
                # add the Steinberg if the rank of V has increased
                if V.rank() == len(lin_indep_steinbergs) + 1:
                    # calculate new column of U
                    if not t_factored:
                        t_factorisation = factorisation(t, prime_list)
                    if not one_minus_t_factored:
                        one_minus_t_factorisation = list(factorisation(1-t, prime_list))
                    for (i_pa, ea) in t_factorisation:
                        if i_pa == iq:
                            continue
                        for (i_pb, eb) in one_minus_t_factorisation:
                            if i_pa == i_pb or i_pb == iq:
                                continue
                            elif i_pa < i_pb:
                                sign = 1
                                i_p1 = i_pa
                                i_p2 = i_pb
                            else:
                                sign = -1
                                i_p1 = i_pb
                                i_p2 = i_pa
                            pair_index = (i_p2*(i_p2-1))//2 + i_p1
                            U[pair_index,len(lin_indep_steinbergs)] += sign*ea*eb
                    # add Steinberg
                    lin_indep_steinbergs.append(t)
                    if len(lin_indep_steinbergs) == dim_increase:
                        break

                else:
                    # reset column in V
                    for i in range(dim_increase):
                        V[i,len(lin_indep_steinbergs)] = 0

        steinberg_basis += lin_indep_steinbergs
        V_inv = V.inverse()
        new_dim = old_dim + dim_increase
        A[old_dim:new_dim, old_dim:new_dim] = V_inv
        A[:old_dim, old_dim:new_dim] = -A[:old_dim, :old_dim]*U*V_inv
        old_dim = new_dim

    decompositions = {}
    prime_pair_index = 0
    for iq in range(len(prime_list)):
        q = prime_list[iq]
        for il in range(iq):
            l = prime_list[il]
            decompositions[l,q] = {steinberg_basis[i] : A[i,prime_pair_index] for i in range(dimension) if A[i,prime_pair_index] != 0}
            prime_pair_index += 1

    return steinberg_basis, decompositions




def check_extrapoint_criterion(bound, prec):
    r"""
    Check criterion from [BBKLMQSX, Prop. 3.12] characterizing for which primes $q > 3$
    the refined CK-set in depth 2 for $S = \{2,q\}$ with $p=3$ contains a point besides $\{-1,2,1/2\}$.

    INPUT:

    - ``bound`` -- upper bound for prime q

    - ``prec`` -- 3-adic precision.
      Increase the precision if the function yields undecided pairs.

    OUTPUT:

    three lists of primes 3 < q < bound such that the refined Chabauty--Kim set
    in depth 2 for S = {2,q} and p=3...
    - ``extrapoint`` -- ...contains an extra point
    - ``noextrapoint`` -- ...contains no extra point
    - ``undecided`` -- cannot be decided due to lack of precision

    EXAMPLES:

    Check the criterion for q < 20:

        sage: extrapoint, noextrapoint, undecided = check_extrapoint_criterion(bound=20, prec=12)
        sage: extrapoint
        [5, 7, 11, 13, 17]
        sage: noextrapoint
        [19]
        sage: undecided
        []

    The algorithm for the bound 500 runs in under 10 minutes:
        sage: extrapoint, noextrapoint, undecided = check_extrapoint_criterion(bound=500,prec=12)
        sage: len(extrapoint)
        79
        sage: len(noextrapoint)
        14
        sage: len(undecided)
        0

    """

    steinbergs, decompositions = steinberg_decompositions(bound, 3)
    prime_list = list(primes(bound))
    needed_precs = determine_needed_precs(prec, steinbergs, decompositions)
    dilog_coeffs = precompute_three_adic_dilog_coeffs(max(needed_precs.values()))
    logs, logs_one_minus, dilogs = precompute_three_adic_logs_and_dilogs(steinbergs, dilog_coeffs, needed_precs)

    prime_logs = {}
    for l in prime_list:
        if l != 3:
            prime_logs[l] = three_adic_log(l, prec)

    extrapoint = []
    noextrapoint = []
    undecided = []
    for iq in range(2, len(prime_list)):
        q = prime_list[iq]
        dec = decompositions[2,q]
        a = three_adic_dcw_coefficient(2, q, dec, prec, logs, logs_one_minus, dilogs)
        b = prime_logs[2] * prime_logs[q] - a
        val_a = a.valuation(3)
        val_b = b.valuation(3)
        val_log_q = (q-1).valuation(3) if q % 3 == 1 else (q+1).valuation(3)
        if val_b >= prec:
            undecided.append(q)
        elif min(val_a,val_b) == 1 + val_log_q:
             extrapoint.append(q)
        else:
             noextrapoint.append(q)
    return extrapoint, noextrapoint, undecided




def three_adic_dcw_coefficients(bound, decompositions, prec):
    r"""
    Tailor-made function for $p = 3$ computing approximations of 3-adic
    DCW coefficients $a_{l,q}$. The DCW coefficients are correct approximations
    up to O(3^prec).

    INPUT:

    - ``bound`` -- upper bound for l and q

    - ``decompositions`` -- dict ``{ (l,q) : dec }`` for $l,q < bound$, $l,q \neq 3$,
      where ``dec`` is a decomposition of $[l] \wedge [q]$ into Steinberg elements:
      $\sum c_i [t_i] \wedge [1-t_i]$, encoded as dict ``{ t_i : c_i }``.

    - ``prec`` -- desired 3-adic precision

    OUTPUT:

    dict { (l,q) : a } for $l,q < bound$, $l,q \neq 3$, where ``a`` is a rational
    number approximating the DCW coefficient $a_{l,q}$ within O(3^prec).

    EXAMPLES:

    Computing 3-adic DCW coefficients $a_{l,q}$ for $l,q < 20$:

        sage: bound = 20
        sage: steinbergs, decompositions = steinberg_decompositions(bound, 3)
        sage: dcw_coeffs = three_adic_dcw_coefficients(bound, decompositions, prec=12)
        sage: dcw_coeffs[5,7]
        247968
        sage: Qp(3,prec=prec)(dcw_coeffs[5,7])
        3^3 + 3^4 + 3^6 + 2*3^7 + 3^8 + 3^10 + 3^11 + O(3^15)

    """

    # collect all used Steinberg elements
    steinbergs = []
    for dec in decompositions.values():
        for t in dec.keys():
                if t not in steinbergs:
                    steinbergs.append(t)

    # precompute 3-adic logarithms and dilogarithms with the necessary precision
    needed_precs = determine_needed_precs(prec, steinbergs, decompositions)
    dilog_coeffs = precompute_three_adic_dilog_coeffs(max(needed_precs.values()))
    logs, logs_one_minus, dilogs = precompute_three_adic_logs_and_dilogs(steinbergs, dilog_coeffs, needed_precs)

    # precompute 3-adic logarithms of primes
    prime_list = list(primes(bound))
    dcw_coeffs = {}
    prime_logs = {}
    for l in prime_list:
        if l != 3:
            prime_logs[l] = three_adic_log(l, prec)

    for iq in range(len(prime_list)):
        q = prime_list[iq]
        if q == 3:
            continue
        dcw_coeffs[q,q] = 1/2 * prime_logs[q]^2
        for il in range(iq):
            l = prime_list[il]
            if l == 3:
                continue
            dec = decompositions[l,q]
            dcw_coeffs[l,q] = three_adic_dcw_coefficient(l, q, dec, prec, logs, logs_one_minus, dilogs)
            # compute a_{q,l} from a_{l,q} via the twisted anti-symmetry relation
            dcw_coeffs[q,l] = prime_logs[l] * prime_logs[q] - dcw_coeffs[l,q]
    return dcw_coeffs





def dcw_coefficients(bound, p, decompositions, prec):
    r"""
    Compute approximations of all p-adic DCW coefficients $a_{l,q}$ up to a given
    bound on $l$ and $q$.

    INPUT:

    - ``bound`` -- upper bound for l and q

    - ``p`` -- odd auxiliary prime

    - ``decompositions`` -- dict ``{ (l,q) : dec }`` for $l,q < bound$, $l,q \neq p$,
      where dec is a decomposition of $[l] \wedge [q]$ into Steinberg elements:
      $\sum c_i [t_i] \wedge [1-t_i]$, encoded as dict ``{ t_i : c_i }``

    - ``prec`` -- p-adic precision

    OUTPUT:

    dict ``{ (l,q) : a_{l,q} }`` for $l,q < bound$, $l,q \neq p$, where $a_{l,q}$
    is an approximation of the DCW coefficient (p-adic number)

    EXAMPLES:

    Computing $a_{l,q}$ for $l,q < 10$ and $p = 5$:

        sage: bound = 10
        sage: p = 5
        sage: steinbergs, decompositions = steinberg_decompositions(bound,prec=12)
        sage: dcw_coeffs = dcw_coefficients(bound, p, decompositions, prec)
        sage: dcw_coeffs[2,7]
        3*5^2 + 4*5^3 + 4*5^5 + 5^6 + O(5^7)

    """

    prime_list = list(primes(bound))
    dcw_coeffs = {}
    F = Qp(p, prec)
    prime_logs = {}
    for l in prime_list:
        if l != p:
            prime_logs[l] = F(l).log()

    for iq in range(len(prime_list)):
        q = prime_list[iq]
        if q == p:
            continue
        dcw_coeffs[q,q] = 1/2 * prime_logs[q]^2
        for il in range(iq):
            l = prime_list[il]
            if l == p:
                continue
            dec = decompositions[l,q]
            dcw_coeffs[l,q] = dcw_coefficient(l, q, p, dec, prec)
            # compute a_{q,l} from a_{l,q} via the twisted anti-symmetry relation
            dcw_coeffs[q,l] = prime_logs[l] * prime_logs[q] - dcw_coeffs[l,q]
    return dcw_coeffs





# For testing purposes
def check_three_adic_commutativity(bound, prec):
    r"""
    Verify that the DCW coefficients computed by ``three_adic_dcw_coefficients``
    are correct: given a,b,c such that $a + b = c$, all coprime to $3$, the
    the commutativity of the Chabauty-Kim diagram on the point $z = a/c$ gives
    a linear equation on the DCW coefficients:

        $\sum_{l,q} a_{l,q} v_l(z) v_q(1-z) = -\Li_2(z)$.

    This condition is checked for all such a + b = c < bound.

    INPUT:

    - ``bound`` -- upper bound on a,b,c

    - ``prec`` -- precision with which DCW coefficients are computed

    OUTPUT:

    Prints triples (a,b,c) with a + b = c < bound where commutativity of the
    Chabauty--Kim diagram fails on $z = a/c$.

    """

    # compute Steinberg decompositions
    steinbergs, decompositions = steinberg_decompositions(bound, 3)

    # precompute dilog coefficients with necessary precision
    needed_precs = determine_needed_precs(prec, steinbergs, decompositions)
    dilog_coeffs = precompute_three_adic_dilog_coeffs(max(needed_precs.values()))

    # compute DCW coefficients
    dcw_coeffs = three_adic_dcw_coefficients(bound, decompositions, prec)

    modulus = 3^prec

    print("checking commutativity...")
    all_correct = True
    for c in range(1,bound):
        if c % 3 == 0:
            continue
        for a in range(1,c):
            b = c - a
            if a % 3 == 0 or b % 3 == 0:
                continue
            z = Rational(a)/c
            S = 0
            for (l,el) in factor(z):
                for (q,eq) in factor(1-z):
                    S += el*eq*dcw_coeffs[l,q]
            S %= modulus
            expected = (-three_adic_dilog_with_coeffs(z % modulus, prec, dilog_coeffs)) % modulus
            if S != expected:
                # print triple (a,b,c) if the a_{l,q} don't satisfy the relation
                # which expresses the commutativity of the CK-diagram for z = a/c
                print("commutativity violated for " + str((a,b,c)))
                all_correct = False
    if all_correct:
    	print("all correct")
    else:
        print("...done")







####################################### AUXILIARY FUNCTIONS #######################################


def modified_dcw(l, q, p):
    r"""
    Modified Dan-Cohen--Wewers algorithm: given primes $l < q$ and $p>2$ such that
    $l, q \neq p$, determine Steinberg elements $[t] \wedge [1-t]$ with $t \leq 1-t$
    (wlog), $t$ and $1-t$ containing only prime factors $\leq q$ but not $p$, such
    that $[l] \wedge [q]$ is in their $\mathbb{Q}$-linear span. Yields only the
    Steinberg elements containing a factor of $q$ (working modulo the span of
    $[l'] \wedge [q']$ with $l' < q' < q$).

    INPUT:

    - ``l`` -- first prime

    - ``q`` -- second prime

    - ``p`` -- odd auxiliary prime

    OUTPUT:

    Yields rational numbers t representing the Steinberg elements $[t] \wedge [1-t]$
    with $t \leq 1-t$, containing only prime factors $\leq q$ but not $p$, such that
    $[l] \wedge [q]$ is in their linear span modulo $[l'] \wedge [q']$ with
    $l' < q' < q$.

    """

    zs = [1] # the list of z_i
    rs = [0] # the list of r_i
    factor_of_two = [False] # list of boolean values to remember if we pick up a factor of two
    repetition = -1 # index of first z_i for which a repetition (up to sign) occurs; -1 while no repetition is found
    # generate sequence of z_i until a repetition occurs; start with z_0 = 1
    z = 1
    while repetition == -1:
        quotient, remainder = divmod(l*z, q)
        # choose z_i' among {remainder + j*b : j = -2,-1,0,1}
        # first consider z_i' with smaller absolute value
        if 2*remainder > q:
            preference = [0,-1,1,-2] # remainder has smaller absolute value than remainder-q
        else:
            preference = [-1,0,1,-2]
        for j in preference:
            s = remainder + j*q
            r = quotient - j
            # check if z_i' is admissible
            if not ( (j == -2 and s % 2 == 1) or (j == 1 and s % 2 == 1) or (s % p == 0) or (r % p == 0) ):
                break # stop the search for admissible z_i if one is found
        # set z_i = z_i'/2 if j = -2 or j = 1, but not if l = 2
        if (j == -2 or j == 1) and (l != 2):
            factor_of_two.append(True)
            z = s // 2
        else:
            factor_of_two.append(False)
            z = s
        # if z_i or -z_i previously encountered, we found a repetition
        if z in zs:
            repetition = zs.index(z)
        elif -z in zs:
            repetition = zs.index(-z)
        # add z_i to the list
        zs.append(z)
        rs.append(r)
    # m < n are the indices of repeating z_i
    m = repetition
    n = len(zs) - 1
    # have [l] \wedge [q] = 1/(n-m) \sum_{i=m+1}^n f_i
    # where f_i = [l] \wedge [q] + [z_{i-1}] \wedge [q] - [z_i] \wedge [q].
    # the f_i have an expression in terms of a Steinberg element and wedges of smaller numbers (Eqs. (2.4) and (2.5));
    # we remember only the Steinberg elements and only if they are not in the span of wedges of smaller primes
    for i in range(m+1,n+1):
        if zs[i] % q == 0 or zs[i-1] % 1 == 0:
            if factor_of_two[i]:
                new_t = 2*zs[i]/(l*zs[i-1])
            else:
                new_t = zs[i]/(l*zs[i-1])
            yield(new_t if 2*new_t <= 1 else 1-new_t)






def three_adic_dcw_coefficient(l, q, decomposition, prec, logs, logs_one_minus, dilogs):
    r"""
    Compute an approximation of a 3-adic DCW coefficient $a_{l,q}$. Requires a
    decomposition of $[l] \wedge [q]$ in terms of Steinberg elements $[t] \wedge [1-t]$,
    and precomputed 3-adic $\log(t)$, $\log(1-t)$, and $\Li_2(t)$.

    INPUT:

    - ``l`` -- first prime

    - ``q`` -- second prime

    - ``decomposition`` -- dict ``{ t_i : c_i }`` such that
      $[l] \wedge [q] = \sum c_i [t_i] \wedge [1-t_i]$

    - ``prec`` -- 3-adic precision

    - ``logs`` -- dict of precomputed 3-adic $\log(t_i)$ (rational number approximation),
      indexed by $t$ appearing in the Steinberg decomposition

    - ``logs_one_minus`` -- dict of precomputed 3-adic $\log(1-t_i)$ (rational number
      approximation)

    - ``dilogs`` -- dict of precomputed 3-adic $\Li_2(t_i)$ (rational number approximation)

    OUTPUT: rational number which approximates the 3-adic DCW coefficient $a_{l,q}$

    """

    if l == 3 or q == 3:
        raise ValueError("The primes l and q need to be different from 3!")

    S = Rational(0)
    if l != q:
        for t, c in decomposition.items():
            S += c * 1/2 * (-2*dilogs[t] - logs[t] * logs_one_minus[t])
    S += 1/2 * three_adic_log(l, prec) * three_adic_log(q, prec)

    val = S.valuation(3)
    if val >= 0:
        S %= 3^prec
    else:
        unit_part = S/3^val
        S = (unit_part % 3^(prec-val)) * 3^val

    return S





def dcw_coefficient(l, q, p, decomposition, prec):
    r"""
    Take primes l, q \neq p and a decomposition of [l] \wedge [q] in terms of Steinberg elements
    and compute an approximation of the DCW coefficient a_{l,q} using the existing SAGE (di-)log functions.

    INPUT:

    - ``l`` -- first prime

    - ``q`` -- second prime

    - ``p`` -- odd auxiliary prime

    - ``decomposition`` -- dict { t_i : c_i } such that [l] \wedge [q] = \sum c_i [t_i] \wedge [1-t_i]

    - ``prec`` -- the precision with which logs and dilogs are computed internally

    OUTPUT:

    the Dan-Cohen--Wewers coefficient a_{l,q} in the depth 2 localization map as a p-adic number

    """

    if l == p or q == p:
        raise ValueError("The primes l and q need to be different from p!")
    F = Qp(p, prec = prec)
    S = F(0)
    for (t,c) in decomposition.items():
        S += c * 1/2 * (-2*cached_dilog(F(t)) - F(1-t).log()*F(t).log())
    S += 1/2 * F(l).log() * F(q).log()
    return S






def determine_needed_precs(desired_prec, steinbergs, decompositions):
    r"""
    Determine the needed (absolute) 3-adic precision of $\log(t)$, $\log(1-t)$,
    $\Li_2(t)$ for each Steinberg element $[t] \wedge [1-t]$ in order to
    guarantee the (absolute) precision ``desired_prec`` of the DCW coefficients.

    INPUT:

    - ``desired_prec`` -- the desired precision for the DCW coefficients

    - ``steinbergs`` -- list of Steinberg elements $t$ for which we want to know
      the needed precision

    - ``decompositions`` -- dict of decompositions of $[l] \wedge [q]$ as $\mathbb{Q}$-
      linear combination of the given Steinberg elements. Each decomposition needs to be
      given as a dict ``{ t_i : c_i }`` where $c_i$ is the coefficient of $[t_i] \wedge [1-t_i]$
      in the decomposition of $[l] \wedge [q]$.

    OUTPUT: dict of the needed precisions indexed by the Steinberg elements $t$

    """

    needed_prec = {}
    for t in steinbergs:
        current_prec = 0
        for dec in decompositions.values():
            if t in dec:
                prec = desired_prec - dec[t].valuation(3)
                if current_prec < prec:
                    current_prec = prec
        needed_prec[t] = current_prec
    return needed_prec






@cached_function
def mod_three_inv_with_prec(x, prec):
    r"""
    Compute the inverse of an integer modulo a power of three (values are cached)

    INPUT:

    - ``x`` - integer which is coprime to 3

    OUTPUT: inverse of $x$ modulo 3^prec if prec > 0, otherwise 0 (integer)

    """

    if prec <= 0:
        return 0
    return inverse_mod(x, 3^prec)



def three_adic_log(z, prec):
    r"""
    Compute 3-adic logarithm of integer up to given precision by hand using power series

    INPUT:

    - ``z`` -- integer not divisible by 3

    - ``prec`` -- desired precision

    OUTPUT: value of 3-adic logarithm of z up to O(3^prec) as an integer

    """

    if z % 3 == 0:
        raise ValueError('z = ' + str(z) + ' is not a 3-adic unit')
    if z % 3 == 2:
        z = 3^prec-z
    if z == 1:
        return 0
    if prec <= 0:
        return 0
    three_power, unit_part, m = split_three_part(1-z)
    unit_power = unit_part
    S = 0
    k = 1
    while 3^(m*k - prec) < k:
        k_three_part, k_unit_part, k_val = split_three_part(k)
        S -= unit_power * mod_three_inv_with_prec(k_unit_part, prec - (m*k - k_val)) * 3^(m*k - k_val)
        unit_power *= unit_part
        k += 1
    return S




def precompute_three_adic_dilog_coeffs(desired_prec):
    r"""
    Precompute coefficients of the power series of the 3-adic dilogarithm. The
    number of coefficients and their precision is chosen so as to be sufficient
    to compute the 3-adic dilogarithms with absolute precision ``desired_prec``
    using the function ``three_adic_dilog_with_coeffs``.

    INPUT:

    - ``desired_prec`` -- the desired precision

    OUTPUT: list of coefficients (integers)

    """
    dilog_coeffs = [0, 0]
    k = 2
    while k <= desired_prec or 3^(k - desired_prec) < k^2:
        (three_part_k, unit_part_k, val_k) = split_three_part(k)
        coeff = 0
        for i in range(1,k):
            (three_part_i, unit_part_i, val_i) = split_three_part(i)
            coeff -= mod_three_inv_with_prec(unit_part_k*unit_part_i*2^(k-i), desired_prec - k + val_k + val_i) * 3^(k - val_k - val_i)
        dilog_coeffs.append(coeff)
        k += 1
    return dilog_coeffs



def three_adic_dilog_with_coeffs(z, prec, coeffs):
    r"""
    Compute 3-adic dilogarithm of integer up to given precision by hand using power
    series for which coefficients where precomputed.

    INPUT:

    - ``z`` -- integer which is congruent 2 mod 3

    - ``prec`` -- desired precision

    - ``coeffs`` -- coefficients of the power series as precomputed
       by ``precompute_three_adic_dilog_coeffs``

    OUTPUT: value of 3-adic dilogarithm of z up to O(3^prec) as an integer

    """

    if z == 2:
        return 0
    if prec <= 0:
        return 0
    m = (2-z).valuation(3)
    if m <= 0:
        raise ValueError('z = ' + str(z) + ' is not in the residue disk of 2 mod 3')
    x = (2-z)//3
    k = 2
    S = 0
    power = x^2
    while 3^(m*k - prec) < k^2:
        if k >= len(coeffs):
            raise ValueError('not enough coefficients given')
        S += coeffs[k] * power
        k += 1
        power *= x
    return S




def precompute_three_adic_logs_and_dilogs(steinbergs, dilog_coeffs, desired_prec):
    r"""
    Precompute 3-adic $\log(t)$, $\log(1-t)$, $\Li_2(t)$ for all Steinbergs $t$.
    This is needed to compute the DCW coefficients $a_{l,q}$ using the functions
    ``three_adic_dcw_coefficient``.

    INPUT:

    - ``steinbergs`` -- list of Steinberg elements t_i

    - ``dilog_coeffs`` -- list of precomputed power series coefficients of 3-adic dilogarithm
      as precomputed by ``precompute_three_adic_dilog_coeffs``

    - ``desired_prec`` -- the desired precision

    OUTPUT: triple consisting of
    - ``logs`` -- dict of $\log(t)$ up to O(3^desired_prec), indexed by Steinbergs $t$
    - ``logs_one_minus`` -- dict of $\log(1-t)$ up to O(3^desired_prec)
    - ``dilogs`` -- dict of $\Li_2(t)$ up to O(3^desired_prec)

    """

    logs = {}
    logs_one_minus = {}
    dilogs = {}
    for t in steinbergs:
        modulus = 3^desired_prec[t]
        logs[t] = three_adic_log(t%modulus, desired_prec[t])
        logs_one_minus[t] = three_adic_log((1-t)%modulus, desired_prec[t])
        dilogs[t] = three_adic_dilog_with_coeffs(t%modulus, desired_prec[t], dilog_coeffs)
    return logs, logs_one_minus, dilogs





def factorisation(x, prime_list):
    r"""
     Yield the factorization of a nonzero rational number using a given list of primes.

     INPUT:
     - ``x`` -- rational number

     - ``prime_list`` -- list of primes

     OUTPUT:

     The prime power factors are yielded as pairs the form (pi,exp) where pi is
     the *index* of the prime in the list, and exp is the exponent.

    """

    num = x.numerator()
    den = x.denominator()
    for pi in range(len(prime_list)):
        p = prime_list[pi]
        if num % p == 0:
            val = 1
            num //= p
            while num % p == 0:
                val += 1
                num //= p
            yield (pi,val)
            if num == 1 and den == 1:
                break
        elif den % p == 0:
            val = 1
            den //= p
            while den % p == 0:
                val += 1
                den //= p
            yield (pi,-val)
            if num == 1 and den == 1:
                break



@cached_function
def split_three_part(n):
    r"""
    Split the maximal power of three off an integer. Results are cached.

    INPUT:

    - ``n`` -- integer

    OUTPUT: triple consisting of:
     - the maximal power of 3 dividing $n$
     - the remaining factor coprime to 3
     - 3-adic valuation of $n$

    """

    if n == 0:
        raise ValueError("Can't split off factors of three from 0")
    three_part = 1
    unit_part = n
    val = 0
    while unit_part % 3 == 0:
        three_part *= 3
        unit_part //= 3
        val += 1
    return (three_part, unit_part, val)




@cached_function
def cached_dilog(x):
    r"""
    Compute p-adic dilogarithm using SAGE library function (values are cached).

    INPUT:

    - ``z`` -- p-adic integer not congruent 0 or 1 mod p

    OUTPUT: approximation of p-adic dilogarithm of $z$ (p-adic integer)

    """

    return x.polylog(2)
