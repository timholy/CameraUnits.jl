"""
```
macro cu_str(unit)
```
String macro to easily recall units located in the `CameraUnits`
package. Although all unit symbols in that package are suffixed with `_cu`,
the suffix should not be used when using this macro.
Note that what goes inside must be parsable as a valid Julia expression.
Examples:
```jldoctest
julia> using Unitful, CameraUnits

julia> 1cu"pco55"
1 cu

julia> uconvert(γe, 1cu"pco55")
0.46 γe
```

Here `"pco55"` stands for the PCO edge 5.5. The second command converts to photoelectrons, using this particular camera's nominal gain.

All cameras have their units display as `"cu"`, although you can get
more information with

```jldoctest
julia> julia> typeof(cu"pco55")
Unitful.Units{(Unitful.Unit{:PCO55,Unitful.Dimensions{()}}(0,1//1),),Unitful.Dimensions{()}}
```
"""
macro cu_str(unit)
    ex = parse(unit)
    esc(replace_value(ex))
end

const allowed_funcs = [:*, :/, :^, :sqrt, :√, :+, :-, ://]
function replace_value(ex::Expr)
    if ex.head == :call
        ex.args[1] in allowed_funcs ||
            error("""$(ex.args[1]) is not a valid function call when parsing a unit.
             Only the following functions are allowed: $allowed_funcs""")
        for i=2:length(ex.args)
            if typeof(ex.args[i])==Symbol || typeof(ex.args[i])==Expr
                ex.args[i]=replace_value(ex.args[i])
            end
        end
        return ex
    elseif ex.head == :tuple
        for i=1:length(ex.args)
            if typeof(ex.args[i])==Symbol
                ex.args[i]=replace_value(ex.args[i])
            else
                error("only use symbols inside the tuple.")
            end
        end
        return ex
    else
        error("Expr head $(ex.head) must equal :call or :tuple")
    end
end

dottify(s, t, u...) = dottify(Expr(:(.), s, QuoteNode(t)), u...)
dottify(s) = s

function replace_value(sym::Symbol)
    s = Symbol(sym, :_cu)
    if !isdefined(CameraUnits, s)
        error("Symbol $s could not be found in CameraUnits.")
    end

    expr = Expr(:(.), dottify(fullname(CameraUnits)...), QuoteNode(s))
    return :(CameraUnits.cutrcheck($expr))
end

replace_value(literal::Number) = literal

cutrcheck(x::Unitful.Unitlike) = x
cutrcheck(x::Unitful.Quantity) = x
cutrcheck(x) = error("Symbol $x is not a unit or quantity.")
