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
- Rasgo has built a starter library of transforms that will also be available to use or fork
- user-defined transforms are written in SQL but accept arguments passed through PyRasgo


# Quick Start
```python
pip install pyrasgo
api_key = '' # Get your api key in the top right corner of the UI
rasgo = pyrasgo.connect(api_key)

transforms = rasgo.get.transforms()
print(transforms)

# Get a source that you want to apply the UDT to
my_source = rasgo.get.data_source(id=100)

#Preview the UDT applied to a source with source.transform().preview()
new_source = my_source.transform(
  transform_name='filter_transform',
  filter_col='CampaignID',
  filter_val='1001'
)

#Ppreview the results of the UDT in a pandas dataframe
new_source.preview()

# Save the new source to Rasgo and your Snowflake Account
new_source.to_source(new_source_name='New Filtered Source')
```
[Read the Docs →](https://docs.rasgoml.com/)

# Available UDTs

## Column Operations
- [rasgo_lag](./column_operations/rasgo_lag/rasgo_lag.sql)
- [rasgo_datetrunc](./column_operations/rasgo_datetrunc/rasgo_datetrunc.sql)
- [rasgo_levenshtein](./column_operations/rasgo_levenshtein/rasgo_levenshtein.sql)

## Table Operations
- [rasgo_pivot](./table_operations/rasgo_pivot/rasgo_pivot.sql)
- [rasgo_group_by](./table_operations/rasgo_group_by/rasgo_group_by.sql)

# About Us
Rasgo UDTs are maintained by *[Rasgo](https://rasgoml.com)*. Rasgo's enterprise feature store integrates with your data warehouse to help users build features faster, collaborate with team members, and serve features to models in production.


<i>Built for Data Scientists, by Data Scientists</i>
