require 'spec_helper'
require 'spec/support/persistence'
require 'routemaster/models/subscribers'
require 'routemaster/models/subscription'

describe Routemaster::Models::Subscribers do
  Subscription = Routemaster::Models::Subscription

  let(:exchange) { double 'exchange' }
  let(:topic) { double 'Topic', name: 'widgets', exchange: exchange }
  subject { described_class.new(topic) }

  describe '#initialize' do
    it 'passes' do
      expect { subject }.not_to raise_error
    end
  end

  describe '#to_a' do
    it 'returns an array' do
      expect(subject.to_a).to be_a_kind_of(Array)
    end
  end

  describe '#each' do
    it 'yields subscriptions' do
      subject.add Subscription.new(subscriber: 'bob')
      expect(subject.count).to eq(1)
      expect(subject.first).to be_a_kind_of(Subscription)
    end
  end

  describe '#add' do
    it 'adds the subscriber' do
      subject.add Subscription.new(subscriber: 'bob')
      expect(subject.first.subscriber).to eq('bob')
    end

    it 'behaves like a set' do
      subject.add Subscription.new(subscriber: 'alice')
      subject.add Subscription.new(subscriber: 'bob')
      subject.add Subscription.new(subscriber: 'alice')
      expect(subject.count).to eq(2)
    end
  end
end

