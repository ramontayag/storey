module Storey
  class StoreyError < StandardError; end
  class SchemaExists < StoreyError; end
  class SchemaNotFound < StoreyError; end
  class TableNotFOund < StoreyError; end
end
