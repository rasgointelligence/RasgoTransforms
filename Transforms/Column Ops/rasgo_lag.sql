-- args: {{Feature}}, {{Amount}}, {{Partition}}, {{OrderBy}}

lag({{Feature}}, {{Amount}}) over (partition by {{Partition}} order by {{OrderBy}}) as Lag_{{Feature}}_{{Amount}}