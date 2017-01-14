defmodule Spec.DefineTest do
  use ExUnit.Case

  use Spec

  describe "defspec" do
    def smart?(iq) when iq > 200, do: true
    def smart?(_), do: false

    defspec nerd, do: %{iq: smart?()}

    test "can be called using conform" do
      assert {:ok, %{iq: 201}} = conform(nerd(), %{iq: 201})
    end

    test "called directly also conforms" do
      assert {:ok, %{iq: 201}} = nerd(%{iq: 201})
    end

    test "called as predicate returns boolean" do
      assert true = nerd?(%{iq: 201})
    end

    test "called with bang returns conformed value only" do
      assert %{iq: 201} = nerd!(%{iq: 201})
    end

    test "called with bang raises on malformed value" do
      assert_raise Spec.Mismatch, fn -> nerd!(%{iq: 2}) end
    end
  end

  describe "defspecp" do
    defspecp kw2, do: is_list() and many({is_atom(), _}, min: 2, max: 2)

    test "can be called using conform" do
      assert {:ok, [a: 1, b: 2]} = conform(kw2(), [a: 1, b: 2])
    end
  end

  describe "first order specs" do
    defspec foo, do: :foo
    defspec bar(baz), do: {:bar, baz}

    test "an spec can be parameter for other" do
      assert {:bar, :foo} = conform!(bar(foo()), {:bar, :foo})
    end
  end
end
