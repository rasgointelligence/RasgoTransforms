<p align="left">
  <img width="90%" href="https://rasgoml.com" target="_blank" src="https://gblobscdn.gitbook.com/assets%2F-MJDKltt3A57jhixTfmu%2F-MJZZeY9BhUCtGPyz6bm%2F-MJZiXHTjQnyVWs6YGPc%2Frasgo-logo-full-color-rgb%20(4).png?alt=media&token=64e56b18-4282-4140-836b-e19c8e2787dc" />
</p>

[![PyPI version](https://badge.fury.io/py/pyrasgo.svg)](https://badge.fury.io/py/pyrasgo)
[![Docs](https://img.shields.io/badge/PyRasgo-DOCS-GREEN.svg)](https://docs.rasgoml.com/)
[![Chat on Slack](https://img.shields.io/badge/chat-on%20Slack-brightgreen.svg)](https://join.slack.com/t/rasgousergroup/shared_invite/zt-nytkq6np-ANEJvbUSbT2Gkvc8JICp3g)
[![Chat on Discourse](https://img.shields.io/discourse/status?server=https%3A%2F%2Fforum.rasgoml.com)](https://forum.rasgoml.com/)

# Rasgo User Defined Transforms (UDTs)

UDTs enable templatized SQL transformation via Rasgo, through a pandas-like interface in PyRasgo.
- user-defined transforms are equivalent to SQL functions that accept a Rasgo Source and return a Rasgo Source
- user-defined transforms are scoped to your organization so they can be shared with colleagues
- Rasgo has built a starter library of transforms for you to use or fork
- user-defined transforms are written in SQL but accept arguments passed through PyRasgo

# Follow Along with a Tutorial

[Here's a Jupyter Notebook](https://github.com/rasgointelligence/RasgoUDTs/blob/main/UDT%20Tutorial.ipynb) to help you get started with UDTs.


# Quick Start
```python
pip install pyrasgo
api_key = '' # Get your api key in the top right corner of the UI
rasgo = pyrasgo.connect(api_key)

transforms = rasgo.get.transforms()
print(transforms)

# Get a source that you want to apply the UDT to
my_source = rasgo.get.data_source(id=100)

#Preview the SQL created by applying a UDT to a source
t1 = my_source.transform(
  transform_name='train_test_split',
  order_by = ['DATE'],
  train_percent = .8
).preview_sql()

#Ppreview the results of running the UDT in a pandas dataframe
t1.preview()

# Save the new source to Rasgo and your Snowflake Account
t1.to_source(new_source_name='New Filtered Source')
```
[Read the Docs →](https://docs.rasgoml.com/)

# Available UDTs
## Column Transforms
- [binning](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/binning)
- [cast](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/cast)
- [concat](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/concat)
- [datediff](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/datediff)
- [datepart](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/datepart)
- [datetrunc](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/datetrunc)
- [drop_columns](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/drop_columns)
- [find_and_replace](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/find_and_replace)
- [if_then](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/if_then)
- [impute](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/impute)
- [lag](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/lag)
- [levenshtein](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/levenshtein)
- [math](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/math)
- [moving_avg](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/moving_avg)
- [one_hot_encode](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/one_hot_encode)
- [rename](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/rename)
- [substring](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/substring)
- [to_date](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/to_date)
- [train_test_split](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/column-transforms/train_test_split)

## Table Transforms
- [aggregate](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/table-transforms/aggregate)
- [datespine](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/table-transforms/datespine)
- [dedupe](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/table-transforms/dedupe)
- [join](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/table-transforms/join)
- [pivot](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/table-transforms/pivot)
- [union](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/table-transforms/union)
- [unpivot](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/table-transforms/unpivot)

## Row Transforms
- [filter](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/row-transforms/filter)
- [order](https://docs.rasgoml.com/rasgo-docs/pyrasgo/user-defined-transforms-udts/row-transforms/order)

# About Us
Rasgo UDTs are maintained by *[Rasgo](https://rasgoml.com)*. Rasgo's enterprise feature store integrates with your data warehouse to help users build features faster, collaborate with team members, and serve features to models in production.


<i>Built for Data Scientists, by Data Scientists</i>
