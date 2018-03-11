defmodule Cards do
  @moduledoc """
    Provides methods for creating and handling a deck of cards
"""

  def create_deck do
    values = ["Ace", "Two", "Tree", "Four", "Five"]
    suits = ["Spades", "Clubs", "Hearts", "Diamonds"]

    # get the every possible combination of suits and values
    for suit <- suits, value <- values do
        "#{value} of #{suit}"
    end
  end

  def shuffle(deck) do
    Enum.shuffle(deck)
  end

  @doc """
  Determines whether a deck contains a given card

  ## Examples
      iex> deck = Cards.create_deck
      iex> Cards.contains?(deck, "Ace of Spades")
      true
"""
  def contains?(deck, handCards) do
      Enum.member?(deck, handCards)
  end

  @doc """
  Divides a deck into a hand and the remainder of the deck.
  The `hand_size` argument indicates how many cards should be in the hand.

  ## Examples

      iex > deck = Cards.create_deck
      iex > {hand, deck} = Cards.deal(deck, 1)
      iex> hand
      ["Ace of Spades"]
  """
  def deal(deck, hand_size) do
    # output is a tuble of { my hand, the rest }
    Enum.split(deck, hand_size)
  end

  def save(deck, filename) do
    binary = :erlang.term_to_binary(deck)
    File.write(filename, binary)
  end

  def load(filename) do
    # {status, binary} = File.read(filename)
    case File.read(filename) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      {:error, _reason} -> "That file does not exist" # underscore _reason means we don't need the variable.
    end
  end

  def create_hand(hand_size) do
    # pipe operator, require us to use consistant first argument
    Cards.create_deck
    |> Cards.shuffle
    |> Cards.deal(hand_size)
  end

end
