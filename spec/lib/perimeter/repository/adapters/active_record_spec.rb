require 'spec_helper'
require 'perimeter/repository/adapters/active_record'
require 'my/games'

describe Perimeter::Repository::Adapters::ActiveRecord do

  let(:repository) { My::Games }
  let(:frontend)   { My::Game }
  let(:backend)    { My::Games::Backend }

  describe '.find' do
    let(:finding) { repository.find 1 }

    context 'the record exists' do
      before do
        backend.create! name: 'Star Wars', genre: 'Classic'
        expect( Trouble ).to_not receive :notify
      end

      it 'is an Operation' do
        expect( finding ).to be_instance_of Operation
      end

      it 'succeeds' do
        expect( finding ).to be_success
      end

      it 'has an informative code' do
        expect( finding.code ).to eq :record_found
      end

      it 'holds the Entity' do
        expect( finding.object ).to be_instance_of frontend
      end

      it 'has all attributes on the Entity' do
        expect( finding.object.attributes ).to eq id: 1, name: 'Star Wars', genre: 'Classic', director: 'Gene Roddenberry'
      end
    end

    context 'the record does not exist' do
      before do
        expect( Trouble ).to_not receive :notify
      end

      it 'is an Operation' do
        expect( finding ).to be_instance_of Operation
      end

      it 'fails' do
        expect( finding ).to be_failure
      end

      it 'has an informative code' do
        expect( finding.code ).to eq :record_not_found
      end

      it 'holds the exception' do
        expect( finding.object ).to be_instance_of ::ActiveRecord::RecordNotFound
      end
    end

    context 'the repository had problems' do
      before do
        allow( repository::Backend ).to receive(:find).and_raise StandardError
        expect( Trouble ).to receive(:notify)
      end

      it 'is an Operation' do
        expect( finding ).to be_instance_of Operation
      end

      it 'fails' do
        expect( finding ).to be_failure
      end

      it 'has an informative code' do
        expect( finding.code ).to eq :backend_error
      end

      it 'holds the exception' do
        expect( finding.object ).to be_instance_of StandardError
      end
    end
  end

  describe '.find!' do
    let(:finding) { repository.find! 1 }

    context 'the record exists' do
      before do
        backend.create! name: 'Casablanca', genre: 'Retro'
        expect( Trouble ).to_not receive :notify
      end

      it 'is an Entity' do
        expect( finding ).to be_instance_of frontend
      end

      it 'has all attributes on the Entity' do
        expect( finding.attributes ).to eq  id: 1, name: 'Casablanca', genre: 'Retro', director: 'Gene Roddenberry'
      end
    end

    context 'the record does not exist' do
      before do
        expect( Trouble ).to_not receive :notify
      end

      it 'raises an Exception' do
        expect { finding }.to raise_error Perimeter::Repository::FindingError
      end
    end

    context 'the repository had problems' do
      before do
        allow( repository::Backend ).to receive(:find).and_raise IOError
        expect( Trouble ).to receive(:notify)
      end

      it 'raises an Exception' do
        expect { finding }.to raise_error Perimeter::Repository::FindingError
      end
    end
  end

  describe '.create' do

    context 'the Record is invalid' do
      let(:creation) { repository.create name: 'Star Trek' }

      before do
        expect( Trouble ).to_not receive :notify
      end

      it 'is an Operation' do
        expect( creation ).to be_instance_of Operation
      end

      it 'fails' do
        expect( creation ).to be_failure
      end

      it 'has an informative code' do
        expect( creation.code ).to eq :validation_failed
      end

      it 'knows the validation that failed on the Entity' do
        expect( creation.object.errors.count ).to eq 1
        expect( creation.object.errors[:genre] ).to be_present
      end

      it 'has all attributes on the Entity' do
        expect( creation.object.attributes ).to eq id: nil, name: 'Star Trek', genre: nil, director: 'Gene Roddenberry'
      end
    end

    context 'record already exists' do
      let(:creation) { repository.create id: 1, name: 'The Matrix Reloaded', genre: 'Documentary' }

      before do
        backend.create! name: 'The Matrix', genre: 'Documentary'
        expect( Trouble ).to_not receive :notify
      end

      it 'is an Operation' do
        expect( creation ).to be_instance_of Operation
      end

      it 'fails' do
        expect( creation ).to be_failure
      end

      it 'has an informative code' do
        expect( creation.code ).to eq :record_already_exists
      end
    end

    context 'persistence fails' do
      let(:creation) { repository.create id: 55, genre: 'Film Noir' }

      before do
        allow( backend ).to receive(:find_by_id) do
          # This is a suitable place to hook in something that will cause the Record#save operation to fail...
          ActiveRecord::Migration.drop_table :games
          nil
        end
        expect( Trouble ).to receive :notify
      end

      it 'is an Operation' do
        expect( creation ).to be_instance_of Operation
      end

      it 'fails' do
        expect( creation ).to be_failure
      end

      it 'has an informative code' do
        expect( creation.code ).to eq :backend_error
      end
    end

    context 'persistence succeeds' do
      let(:creation) { repository.create genre: 'Slapstick' }

      before do
        expect( Trouble ).to_not receive :notify
      end

      it 'is an Operation' do
        expect( creation ).to be_instance_of Operation
      end

      it 'succeeds' do
        expect( creation ).to be_success
      end

      it 'has an informative code' do
        expect( creation.code ).to eq :record_created
      end

      it 'holds the Entity' do
        expect( creation.object ).to be_instance_of frontend
      end

      it 'has all attributes on the Entity' do
        expect( creation.object.attributes ).to eq id: 1, name: nil, genre: 'Slapstick', director: 'Gene Roddenberry'
      end
    end

  end

  describe '.update' do
    context 'record does not exist' do
      let(:updating) { repository.update 1, {} }

      before do
        expect( Trouble ).to_not receive :notify
      end

      it 'is an Operation' do
        expect( updating ).to be_instance_of Operation
      end

      it 'fails' do
        expect( updating ).to be_failure
      end

      it 'has an informative code' do
        expect( updating.code ).to eq :record_not_found
      end
    end

    context 'the Record is invalid' do
      let(:updating) { repository.update 1, name: 'Pac Man', genre: '  ' }

      before do
        backend.create! genre: 'RPG'
        expect( Trouble ).to_not receive :notify
      end

      it 'is an Operation' do
        expect( updating ).to be_instance_of Operation
      end

      it 'fails' do
        expect( updating ).to be_failure
      end

      it 'has an informative code' do
        expect( updating.code ).to eq :validation_failed
      end

      it 'knows the validation that failed on the Entity' do
        expect( updating.object.errors.count ).to eq 1
        expect( updating.object.errors[:genre] ).to be_present
      end

      it 'has all attributes on the Entity' do
        expect( updating.object.attributes ).to eq id: 1, name: 'Pac Man', genre: '  ', director: 'Gene Roddenberry'
      end
    end

    context 'persistence fails' do
      let(:updating) { repository.update 1, name: 'Atomic Bomberman' }

      before do
        backend.create! genre: 'RTS'
        allow( backend ).to receive(:find_by_id) do |id|
          # This is a suitable place to hook in something that will cause the Record#save operation to fail...
          record = backend.find id
          ActiveRecord::Migration.drop_table :games
          record
        end
        expect( Trouble ).to receive :notify
      end

      it 'is an Operation' do
        expect( updating ).to be_instance_of Operation
      end

      it 'fails' do
        expect( updating ).to be_failure
      end

      it 'has an informative code' do
        expect( updating.code ).to eq :backend_error
      end
    end

    context 'persistence succeeds' do
      let(:updating) { repository.update 1, name: 'Alice and Bob' }

      before do
        backend.create! genre: 'Romance'
        expect( Trouble ).to_not receive :notify
      end

      it 'is an Operation' do
        expect( updating ).to be_instance_of Operation
      end

      it 'succeeds' do
        expect( updating ).to be_success
      end

      it 'has an informative code' do
        expect( updating.code ).to eq :record_updated
      end

      it 'holds the Entity' do
        expect( updating.object ).to be_instance_of frontend
      end

      it 'has all attributes on the Entity' do
        expect( updating.object.attributes ).to eq id: 1, name: 'Alice and Bob', genre: 'Romance', director: 'Gene Roddenberry'
      end
    end
  end

end
