RSpec::Matchers.define :have_title do |text|
  match do |page|
    within('#content') do
      page.has_css?('h1', text: text)
    end
  end
end

RSpec::Matchers.define :have_sub_title do |text|
  match do |page|
    within('#content') do
      page.has_css?('h2', text: text)
    end
  end
end
