module Storey
  class StoreyError < StandardError; end
  class SchemaExists < StoreyError; end
  class SchemaReserved < StoreyError; end
  class SchemaInvalid < StoreyError; end
  class SchemaNotFound < StoreyError; end
  class TableNotFOund < StoreyError; end
  class WithinTransaction < StoreyError; end
end
