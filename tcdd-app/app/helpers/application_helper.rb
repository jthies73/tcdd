module ApplicationHelper
  def button_classes(color)
    "inline-flex items-center gap-x-4 rounded-4xl bg-#{color}-600 pl-5 pr-7 py-3 text-xl font-semibold text-white shadow-sm hover:bg-#{color}-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-#{color}-600 cursor-pointer"
  end

  def badge_classes(color)
    "inline-flex items-center rounded-full text-#{color}-600 bg-#{color}-100 px-2 py-1 text-xs font-medium"
  end
end
