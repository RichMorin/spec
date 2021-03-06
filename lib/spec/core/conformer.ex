defprotocol Spec.Conformer do
  alias Spec.Mismatch

  @type conformed :: {:ok, conformed :: any}
  @type mismatch  :: {:error, mismatch :: Mismatch.t}
  @type result :: conformed | mismatch
  @type quoted :: Macro.t
  @type fun :: (any -> result | any)

  @spec conform(conformer :: t, value :: any) :: result
  def conform(conformer, value)
end

defimpl Spec.Conformer, for: Function do
  def conform(fun, value) do
    value
    |> fun.()
    |> Spec.Quoted.result(value, inspect(fun))
  end
end

defimpl Spec.Conformer, for: Spec.Literal do
  def conform(lit, value) when lit == value do
    {:ok, value}
  end
  def conform(lit, value) do
    Spec.Mismatch.error(subject: value, reason: "does not match", expr: lit)
  end
end

defimpl Spec.Conformer, for: Integer do
  alias Spec.Conformer.Spec.Literal
  def conform(lit, value), do: Literal.conform(lit, value)
end

defimpl Spec.Conformer, for: Float do
  alias Spec.Conformer.Spec.Literal
  def conform(lit, value), do: Literal.conform(lit, value)
end

defimpl Spec.Conformer, for: String do
  alias Spec.Conformer.Spec.Literal
  def conform(lit, value), do: Literal.conform(lit, value)
end

defimpl Spec.Conformer, for: Atom do
  alias Spec.Conformer.Spec.Literal
  def conform(lit, value), do: Literal.conform(lit, value)
end

defimpl Spec.Conformer, for: Regex do
  def conform(regex, value) do
    captures = Regex.named_captures(regex, value)
    cond do
      is_map(captures) and map_size(captures) > 0 -> {:ok, captures}
      is_map(captures) -> {:ok, value}
      :else ->
        Spec.Mismatch.error(subject: value, reason: "does not match regex", expr: regex)
    end
  end
end
