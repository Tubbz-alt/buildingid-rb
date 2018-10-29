# Unique Building Identification (UBID)

**Website:** https://buildingid.pnnl.gov/

## Documentation

### Install

Add this line to your application's Gemfile:

```ruby
gem 'pnnl-building_id'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install pnnl-building_id
```

## Usage

The `pnnl-building_id` package supports one usage:
* Application programming interface (API)

### The API

UBID codecs are encapsulated in separate modules:
* `PNNL::BuildingId::V3` (format: "C-n-e-s-w")

Modules export the same API:
* `decode(String) ~> PNNL::BuildingId::CodeArea`
* `encode(Float, Float, Float, Float, Float, Float, Integer) ~> String`
* `encode_code_area(PNNL::BuildingId::CodeArea) ~> String`
* `valid?(String) ~> Boolean`

In the following example, a UBID code is decoded and then re-encoded:

```ruby
# Use the "C-n-e-s-w" format for UBID codes.
require 'pnnl/building_id'

# Initialize UBID code.
code = '849VQJH6+95J-51-58-42-50'
$stdout.puts(code)

# Decode the UBID code.
code_area = PNNL::BuildingId::V3.decode(code)
$stdout.puts(code_area)

# Resize the resulting UBID code area.
#
# The effect of this operation is that the height and width of the UBID code
# area are reduced by half an OLC code area.
new_code_area = code_area.resize
$stdout.puts(new_code_area)

# Encode the new UBID code area.
new_code = PNNL::BuildingId::V3.encode_code_area(new_code_area)
$stdout.puts(new_code)

# Test that the new UBID code matches the original.
$stdout.puts(code == newCode)
```

## License

The gem is available as open source under the terms of the [3-Clause BSD License](https://opensource.org/licenses/BSD-3-Clause).

## Contributions

Contributions are accepted on [GitHub](https://github.com/) via the fork and pull request workflow. See [here](https://help.github.com/articles/using-pull-requests/) for more information.
