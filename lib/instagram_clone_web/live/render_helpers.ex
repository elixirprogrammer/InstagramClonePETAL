defmodule InstagramCloneWeb.RenderHelpers do

  def selected_link?(current_uri, menu_link) when current_uri == menu_link do
    "border-l-2 border-black -ml-0.5 text-gray-900 font-semibold"
  end

  def selected_link?(_current_uri, _menu_link) do
    "hover:border-l-2 -ml-0.5 hover:border-gray-300 hover:bg-gray-50"
  end
end
