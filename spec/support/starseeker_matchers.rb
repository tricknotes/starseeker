RSpec::Matchers.define :have_caption do |text|
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

RSpec::Matchers.define :have_flash do |message|
  match do |page|
    within('header') do
      page.has_css?('#notice', text: message)
    end
  end
end

RSpec::Matchers.define :have_list do |text|
  match do |page|
    within('#content') do
      page.has_css?('li', text: text, count: 1)
    end
  end
end
