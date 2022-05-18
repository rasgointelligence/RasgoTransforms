def infer_columns(args, source_columns) -> dict:
    out_columns = {}
    out_columns[f"{args['agg_column']}_listagg"] = 'varchar'
    out_columns["NumTransactions"] = 'integer'
    return out_columns
