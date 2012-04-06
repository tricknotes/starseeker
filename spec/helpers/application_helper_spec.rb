require 'spec_helper'

describe ApplicationHelper do
  describe '#gravatar_url' do
    it 'should cantains gravatar_id' do
      gravatar_url('TEST').should match(%r{https://secure.gravatar.com/avatar/TEST})
    end
  end

  describe '#github_url' do
    it 'should contains name' do
      github_url('ACTOR').should eq('https://github.com/ACTOR')
    end
  end
end
