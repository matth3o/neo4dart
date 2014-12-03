part of neo4dart;

class CypherDeleteExecutor extends CypherExecutor {

  final _logger = new Logger("CypherDeleteExecutor");

  CypherDeleteExecutor() {
    client = new http.Client();
  }

  CypherDeleteExecutor.withClient(client) : super.withClient(client);

  Future deleteNode(Node node, Type type, {bool force: false}) {

    String query = new CypherDeleteBuilder().buildQueryToDeleteNodes([node.id], type, force: force);
    return executeCypher(query);
  }

  Future deleteNodes(Iterable<Node> nodes) {
    return null;
  }

  Future deleteRelation(Relation relation) {
    return null;
  }

  Future deleteRelations(Iterable<Relation> relations) {
    return null;
  }
}