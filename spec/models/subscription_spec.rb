require 'spec_helper'
require 'spec/support/persistence'
require 'routemaster/models/subscription'
require 'routemaster/models/subscribers'
require 'routemaster/models/queue'
require 'routemaster/models/message'
require 'routemaster/models/topic'

describe Routemaster::Models::Subscription do
  subject { described_class.new(subscriber: 'bob') }

  describe '#initialize' do
    it 'passes' do
      expect { subject }.not_to raise_error
    end
  end

  describe '#timeout=' do
    it 'accepts integers' do
      expect { subject.timeout = 123 }.not_to raise_error
    end

    it 'rejects strings' do
      expect { subject.timeout = '123' }.to raise_error(ArgumentError)
    end

    it 'rejects negatives' do
      expect { subject.timeout = -123 }.to raise_error(ArgumentError)
    end

  end

  describe '#timeout' do
    it 'returns a default value if unset' do
      expect(subject.timeout).to eq(described_class::DEFAULT_TIMEOUT)
    end

    it 'returns an integer' do
      subject.timeout = 123
      expect(subject.timeout).to eq(123)
    end
  end

  describe '.each' do

    it 'does not yield when no subscriptions are present' do
      expect { |b| described_class.each(&b) }.not_to yield_control
    end

    it 'yields subscriptions' do
      a = described_class.new(subscriber: 'alice')
      b = described_class.new(subscriber: 'bob')

      expect { |b| described_class.each(&b) }.to yield_control.twice
    end
  end

  describe '#topics' do

    let(:properties_topic) do
      Routemaster::Models::Topic.new(name: 'properties', publisher: 'demo')
    end

    let(:property_photos_topic) do
      Routemaster::Models::Topic.new(name: 'photos', publisher: 'demo')
    end

    before do
      subscriber1 = Routemaster::Models::Subscribers.new(properties_topic)
      subscriber1.add(subject)
      subscriber2 = Routemaster::Models::Subscribers.new(property_photos_topic)
      subscriber2.add(subject)
    end

    it 'returns an array of associated topics' do
      expect(subject.topics.map{|x|x.name}.sort)
        .to eql(['photos','properties'])
    end
  end

  describe '#all_topics_count' do
    let(:properties_topic) do
      Routemaster::Models::Topic.new({
        name: 'properties',
        publisher: 'demo'
      })
    end
    let(:property_photos_topic) do
      Routemaster::Models::Topic.new({
        name: 'photos',
        publisher: 'demo'
      })
    end

    before do
      subscriber1 = Routemaster::Models::Subscribers.new(properties_topic)
      subscriber1.add(subject)
      subscriber2 = Routemaster::Models::Subscribers.new(property_photos_topic)
      subscriber2.add(subject)
    end

    it 'should sum the cumulative totals for all associated topics' do
      allow(subject)
        .to receive(:topics)
        .and_return([properties_topic, property_photos_topic])
      allow(properties_topic)
        .to receive(:get_count)
        .and_return(100)
      allow(property_photos_topic)
        .to receive(:get_count)
        .and_return(200)

      expect(subject.all_topics_count).to eql 300
    end
  end

  describe '.age_of_oldest_message' do

    let(:subscription) {
      Routemaster::Models::Subscription.new(subscriber: 'alice')
    }
    let(:options) {[ subscription ]}
    let(:consumer) { Routemaster::Models::Queue.new(*options) }
    let(:event) {
      Routemaster::Models::Event.new(
        topic: 'widgets',
        type:  'create',
        url:   'https://example.com/widgets/123'
      )
    }

    before do
      Routemaster::Models::Queue.push [subscription], Routemaster::Models::Message.new(event.dump)
    end

    it 'should return the age of the oldest message' do
      sleep(250e-3)
      expect(subscription.age_of_oldest_message).to be_within(50).of(250)
    end

    it 'does not dequeue the oldest message' do
      subscription.age_of_oldest_message
      expect(consumer.pop).to be_event
    end
  end
end
