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
    defspecp foo, do: :foo
    defspecp bar(baz), do: {:bar, baz}
    defspecp bat(baz), do: {:bat, baz.()}
    defspecp moo(x), do: {:moo, dos(11)}
    defspecp dos(n), do: n * 2

    test "an spec can be parameter for other" do
      assert {:bar, :foo} = conform!(bar(foo()), {:bar, :foo})
    end

    test "an spec can be given a reference of another" do
      assert {:bat, :foo} = conform!(bat(&foo/1), {:bat, :foo})
    end

    test "an spec can be given a reference that expects an arg" do
      assert {:moo, 22} = conform!(moo(&dos/1), {:moo, 22})
    end
  end
end
