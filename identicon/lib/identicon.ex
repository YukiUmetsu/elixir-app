defmodule Identicon do
  @moduledoc """
  This app takes an input string and create symmetric icon image based on the input string.
  """

  @doc """
  Input: string (this becomes file name of the image)
    input
      |> hash_input
      |> pick_color
      |> build_grid
      |> filter_odd_squares
      |> build_pixel_map
      |> draw_image
      |> save_image(input)
"""
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Input: string
  Return: a hashed list of 16 numbers between 0-255
"""
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
  Input: Identicon Image struct and destruct with pattern matching.
  Logic: separate the list into chunks with 3 numbers and create the grid with 5 numbers.
  Return: Identicon.Image struct with grid property.
"""
  def pick_color(%Identicon.Image{hex: [r,g,b | _tail ] } = image) do
    %Identicon.Image{ image | color: {r,g,b}} # add rgb color to the struct.
  end

  @doc """
  Input: struct with a list of hashed numbers.
  create a list with tuples of the value and index.
"""
  def build_grid(%Identicon.Image{hex: hex_list } = image) do
    grid =
      hex_list
      |> Enum.chunk(3) # separate the list to chunks of 3 values
      |> Enum.map(&mirror_row/1) # & tells that we are passing arguments. /1 means passing one argument.
      |> List.flatten
      |> Enum.with_index # create a list with tuples of the value and index

    %Identicon.Image{image | grid: grid} # add grid into the image struct
  end

  @doc """
  Input: a list of 3 numbers. ex) [1,2,3]
  Return: a list of 5 numbers with symmetric values. ex) [1,2,3,2,1]
"""
  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  @doc """
  Input: an image struct
  Return: tuples with only even numbers
"""
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Input Image struct.
  Return: a list of points to color.
"""
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5)*50
      vertical = div(index, 5)*50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal+50, vertical+50}
      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
  Draw an image from the pixel map with erlang drawing library.
"""
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop})->
      :egd.filledRectangle(image, start, stop, fill)
    end
    :egd.render(image)
  end

  @doc """
  Input: image and file name as string
  Saves an image
"""
  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

end
