def infer_columns(args, source_columns) -> dict:
    out_columns = {}
    out_columns[f"{args['agg_column']}_listagg"] = 'text'
    out_columns["NumTransactions"] = 'int'
    return out_columns
