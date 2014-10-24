library neo4dart.client.batch.batch_token_handler_test;

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';

import 'package:logging/logging.dart';

import 'package:neo4dart/testing/person.dart';
import 'package:neo4dart/testing/love.dart';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.client.batch.batch_token_handler_test");

  group('addNodeToBatch', () {

    test('ok', () {
        Node node = new Person("Claude", city: "Gagny");

        BatchTokenHandler handler = new BatchTokenHandler();
        BatchToken token = handler.addNodeToBatch(node);

        BatchToken expected = new BatchToken("POST", "/node", {"name" : "Claude", "city" : "Gagny"});

        expect(token, equals(expected));
    });
  });

  group('addNodesToBatch', () {

    test('ok', () {
      Set<Node> nodes = new Set();
      nodes.add(new Person("Claude", city: "Gagny"));
      nodes.add(new Person("Liliane", city: "Gagny"));

      BatchTokenHandler handler = new BatchTokenHandler();
      Set<BatchToken> tokens = handler.addNodesToBatch(nodes);

      List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Claude", "city" : "Gagny"}),
                                   new BatchToken("POST", "/node", {"name" : "Liliane", "city": "Gagny"}, id: 2)];

      expect(tokens, unorderedEquals(expected));
    });
  });

  group('addNodeAndRelationsToBatch', () {

    test('ok - inDepth set to true', () {
        Person tintin = new Person("Tintin", city: "Tibet");
        var milou = new Person("Milou", city: "BoneLand");
        var haddock = new Person("Haddock", city: "Boat");
        tintin.coworkers = [milou, haddock];
        var tournesol = new Person("Tournesol", city: "Laboratory");
        haddock.coworkers = [tournesol];

        BatchTokenHandler handler = new BatchTokenHandler();
        Set<BatchToken> tokens = handler.addNodeAndRelationsToBatch(tintin, true);

        List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Tintin", "city": "Tibet"}, id: 0),
                                     new BatchToken("POST", "/node", {"name" : "Milou", "city": "BoneLand"}, id: 2),
                                     new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': null, 'type': 'works with'}),
                                     new BatchToken("POST", "/node", {"name" : "Haddock", "city": "Boat"}, id: 2),
                                     new BatchToken("POST", "{0}/relationships", {'to': '{5}', 'data': null, 'type': 'works with'}),
                                     new BatchToken("POST", "/node", {"name" : "Tournesol", "city": "Laboratory"}, id: 8),
                                     new BatchToken("POST", "{5}/relationships", {'to': '{8}', 'data': null, 'type': 'works with'})];

        expect(tokens, unorderedEquals(expected));
    });

    test('ok - inDepth set to false', () {
     Person tintin = new Person("Tintin", city: "Tibet");
     var milou = new Person("Milou", city: "BoneLand");
     var haddock = new Person("Haddock", city: "Boat");
     tintin.coworkers = [milou, haddock];
     var tournesol = new Person("Tournesol", city: "Laboratory");
     haddock.coworkers = [tournesol];

     BatchTokenHandler handler = new BatchTokenHandler();
     Set<BatchToken> tokens = handler.addNodeAndRelationsToBatch(tintin, false);

     List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Tintin", "city": "Tibet"}, id: 0),
                                  new BatchToken("POST", "/node", {"name" : "Milou", "city": "BoneLand"}, id: 2),
                                  new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': null, 'type': 'works with'}),
                                  new BatchToken("POST", "/node", {"name" : "Haddock", "city": "Boat"}, id: 2),
                                  new BatchToken("POST", "{0}/relationships", {'to': '{5}', 'data': null, 'type': 'works with'})];

     expect(tokens, unorderedEquals(expected));
    });
  });

  group('addNodesAndRelationsToBatch', () {

    test('ok', () {
      Person tintin = new Person("Tintin", city: "Tibet");
      Person milou = new Person("Milou", city: "BoneLand");
      tintin.coworkers = [milou];

      Person haddock = new Person("Haddock", city: "Boat");
      Person tournesol = new Person("Tournesol", city: "Laboratory");
      haddock.coworkers = [tournesol];

      BatchTokenHandler handler = new BatchTokenHandler();
      Set<BatchToken> tokens = handler.addNodesAndRelationsToBatch([tintin, haddock], true);

      List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Tintin", "city": "Tibet"}, id: 0),
                                   new BatchToken("POST", "/node", {"name" : "Milou", "city": "BoneLand"}, id: 2),
                                   new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': null, 'type': 'works with'}),
                                   new BatchToken("POST", "/node", {"name" : "Haddock", "city": "Boat"}, id: 2),
                                   new BatchToken("POST", "/node", {"name" : "Tournesol", "city": "Laboratory"}, id: 8),
                                   new BatchToken("POST", "{5}/relationships", {'to': '{7}', 'data': null, 'type': 'works with'})];

      expect(tokens, unorderedEquals(expected));
    });
  });

  group('addNodeAndRelationsViaToBatch', () {

    test('ok - inDepth set to true', () {
      Person romeo = new Person("Romeo", city: "Roma");
      Person julieta = new Person("Julieta", city: "Venizia");
      Person liliana = new Person("Liliana", city: "Friul");

      romeo.eternalLovers.add(new Love(romeo, julieta, "so so", "1345"));
      romeo.eternalLovers.add(new Love(romeo, liliana, "so so so", "1346"));

      Person eduardo = new Person("Eduardo", city: "Moscow");
      liliana.eternalLovers.add(new Love(liliana, eduardo, "so so so so", "1919"));

      BatchTokenHandler handler = new BatchTokenHandler();
      Set<BatchToken> tokens = handler.addNodeAndRelationsViaToBatch(romeo, true);

      List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Romeo", "city": "Roma"}, id: 0),
                                   new BatchToken("POST", "/node", {"name" : "Julieta", "city": "Venizia"}, id: 2),
                                   new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': {'howMuch': 'so so', 'since': 1345}, 'type': 'secretly loves'}),
                                   new BatchToken("POST", "/node", {"name" : "Liliana", "city": "Friul"}, id: 4),
                                   new BatchToken("POST", "{0}/relationships", {'to': '{5}', 'data': {'howMuch': 'so so so', 'since': 1346}, 'type': 'secretly loves'}),
                                   new BatchToken("POST", "/node", {"name" : "Eduardo", "city": "Moscow"}, id: 8),
                                   new BatchToken("POST", "{5}/relationships", {'to': '{8}', 'data': {'howMuch': 'so so so so', 'since': 1919}, 'type': 'secretly loves'})];

      expect(tokens, unorderedEquals(expected));
    });

    test('ok - inDepth set to false', () {
      Person romeo = new Person("Romeo", city: "Roma");
      Person julieta = new Person("Julieta", city: "Venizia");
      Person liliana = new Person("Liliana", city: "Friul");

      romeo.eternalLovers.add(new Love(romeo, julieta, "so so", "1345"));
      romeo.eternalLovers.add(new Love(romeo, liliana, "so so so", "1346"));

      Person eduardo = new Person("Eduardo", city: "Moscow");
      liliana.eternalLovers.add(new Love(liliana, eduardo, "so so so so", "1919"));

      BatchTokenHandler handler = new BatchTokenHandler();
      Set<BatchToken> tokens = handler.addNodeAndRelationsViaToBatch(romeo, false);

      List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Romeo", "city": "Roma"}, id: 0),
                                   new BatchToken("POST", "/node", {"name" : "Julieta", "city": "Venizia"}, id: 2),
                                   new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': {'howMuch': 'so so', 'since': 1345}, 'type': 'secretly loves'}),
                                   new BatchToken("POST", "/node", {"name" : "Liliana", "city": "Friul"}, id: 4),
                                   new BatchToken("POST", "{0}/relationships", {'to': '{5}', 'data': {'howMuch': 'so so so', 'since': 1346}, 'type': 'secretly loves'})];

      expect(tokens, unorderedEquals(expected));
    });
  });

  group('addNodesAndRelationsViaToBatch', () {

    test('ok', () {
      Person romeo = new Person("Romeo", city: "Roma");
      Person julieta = new Person("Julieta", city: "Venizia");
      romeo.eternalLovers.add(new Love(romeo, julieta, "so so", "1345"));

      Person liliana = new Person("Liliana", city: "Friul");
      Person eduardo = new Person("Eduardo", city: "Moscow");
      liliana.eternalLovers.add(new Love(liliana, eduardo, "so so so so", "1919"));

      BatchTokenHandler handler = new BatchTokenHandler();
      Set<BatchToken> tokens = handler.addNodesAndRelationsViaToBatch([romeo, liliana], true);

      List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Romeo", "city": "Roma"}, id: 0),
                                   new BatchToken("POST", "/node", {"name" : "Julieta", "city": "Venizia"}, id: 2),
                                   new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': {'howMuch': 'so so', 'since': 1345}, 'type': 'secretly loves'}),
                                   new BatchToken("POST", "/node", {"name" : "Liliana", "city": "Friul"}, id: 5),
                                   new BatchToken("POST", "/node", {"name" : "Eduardo", "city": "Moscow"}, id: 7),
                                   new BatchToken("POST", "{5}/relationships", {'to': '{7}', 'data': {'howMuch': 'so so so so', 'since': 1919}, 'type': 'secretly loves'})];

      expect(tokens, unorderedEquals(expected));
    });
  });

}
