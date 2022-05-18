def infer_columns(args, source_columns) -> dict:
    concat_list = [c.upper() for c in args['concat_list']]
    if 'overwrite_columns' in args and args['overwrite_columns']:
        out_cols = {k: v for k, v in source_columns.items() if k.upper() not in concat_list}
    else:
        out_cols = source_columns
    out_cols[F'CONCAT_{"_".join(concat_list)}'] = 'string'
    return out_cols
