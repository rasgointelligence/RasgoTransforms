def infer_columns(args, source_columns) -> dict:
    out_columns = {k: v for k, v in source_columns.items() if k in args['group_by']}
    out_columns['Slope'] = 'double'
    out_columns['Intercept'] = 'double'
    out_columns['R2'] = 'double'
    out_columns['Formula'] = 'varchar'
    return out_columns
