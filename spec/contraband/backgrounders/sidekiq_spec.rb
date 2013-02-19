require 'spec_helper'

describe Contraband::Backgrounders::Sidekiq do

  describe '#initialize' do

    context 'when options are not present' do

      it 'does not set Sidekiq options' do
        pending
      end
    end

    context 'when options are present' do

      it 'sets provided options on Sidekiq worker' do
        pending
      end
    end
  end

  describe '#enqueue' do

    it 'calls #perform_async on worker class with import data' do
      pending
    end
  end

  describe '#worker_class' do

    context 'when initialized with a worker class' do

      it 'returns the configured worker' do
        pending
      end
    end

    context 'when not initialized with a worker class' do

      it 'returns the default worker' do
        pending
      end
    end
  end
end