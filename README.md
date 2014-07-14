# Perimeter

An ActiveRecord adapter for [Perimeter](https://github.com/bukowskis/perimeter).

```ruby
require 'perimeter/repository/adapters/active_record'

# Repository
module Books
  include Perimeter::Repository::Adapters::ActiveRecord
end
```

```ruby
require 'perimeter/backend/adapters/active_record'

# Backend
module Books
  class Backend < ActiveRecord::Base
    include Perimeter::Backend::Adapters::ActiveRecord
  end
end
```

# License

See `MIT-LICENSE` for details.
