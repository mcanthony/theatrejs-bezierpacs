BezierPacs = require '../../src/BezierPacs'
Point = require '../../src/bezierPacs/Point'

describe "Point", ->

	describe "constructor()", ->

		it "should work", ->

			(new BezierPacs).createPoint()

	describe "belongTo()", ->

		it "point should not have an id before calling belongTo()", ->

			pacs = new BezierPacs

			p = pacs.createPoint()

			expect(p._id).to.equal null

		it "point should get an id after calling belongTo()", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			expect(p._id).to.not.equal null

		it "should get the point owned by a pacs", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			p._pacs.should.equal pacs

		it "should throw if the point already belongs to a pacs", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			(-> p.belongTo pacs).should.throw()

	describe "disbelong()", ->

		it "should get the point disowned by the pacs", ->

			pacs = new BezierPacs

			p = pacs.createPoint()

			p.belongTo pacs

			p.disbelong()

			expect(p._pacs).to.equal null

		it "should not make the point lose its id", ->

			pacs = new BezierPacs

			p = pacs.createPoint()

			p.belongTo pacs

			id = p._id

			p.disbelong

			p._id.should.equal id

		it "should throw if the point doesn't belong to any pacs", ->

			pacs = new BezierPacs

			p = pacs.createPoint()

			(-> p.disbelong()).should.throw()

		it "should throw if the point is already inserted in sequence", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			p.insert()

			(-> p.disbelong()).should.throw()

	describe "insert()", ->

		it "should get the point inserted the point in sequence", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			p.insert()

			p._list.should.equal pacs._list
			p._sequence.should.equal pacs._list._pointsInSequence
			pacs._list._pointsInSequence[0].should.equal p

		it "should throw if the point isn't owned by any pacs yet", ->

			pacs = new BezierPacs

			p = pacs.createPoint()

			(-> p.insert()).should.throw()

		it "should throw if the point is already inserted", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			p.insert()

			(-> p.insert()).should.throw()

	describe "_getInsertedInSequence()", ->

		it "should properly link to next/prev points", ->

			pacs = new BezierPacs

			points = []

			for i in [0..2]

				points.push pacs.createPoint().belongTo(pacs).setTime(i * 100).insert()

			expect(points[0]._leftPoint).to.equal null
			expect(points[0]._rightPoint).to.equal points[1]

			expect(points[1]._leftPoint).to.equal points[0]
			expect(points[1]._rightPoint).to.equal points[2]

			expect(points[2]._leftPoint).to.equal points[1]
			expect(points[2]._rightPoint).to.equal null

			for p in points

				p.remove().insert()

			expect(points[0]._leftPoint).to.equal null
			expect(points[0]._rightPoint).to.equal points[1]

			expect(points[1]._leftPoint).to.equal points[0]
			expect(points[1]._rightPoint).to.equal points[2]

			expect(points[2]._leftPoint).to.equal points[1]
			expect(points[2]._rightPoint).to.equal null

			return

		it "should throw if it gets in between a connection", ->

			pacs = new BezierPacs

			p1 = pacs.createPoint().setTime(0).belongTo(pacs).insert()
			p2 = pacs.createPoint().setTime(100).belongTo(pacs).insert()
			p1.connectToRight()

			p3 = pacs.createPoint().setTime(50).belongTo(pacs)

			(-> p3.insert()).should.throw()

	describe "remove()", ->

		it "should get the point removed from the sequence", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			p.insert()

			p.remove()

			expect(p._sequence).to.equal null
			pacs._list._pointsInSequence.should.not.contain p

		it "should throw if the point is not in sequence", ->

			pacs = new BezierPacs

			p = pacs.createPoint()
			p.belongTo pacs

			(-> p.remove()).should.throw()

	describe "_getRemovedFromSequence()", ->

		it "should reset the links", ->

			pacs = new BezierPacs

			points = []

			for i in [0..2]

				points.push pacs.createPoint().belongTo(pacs).setTime(i * 100).insert()

			points[1].remove()

			expect(points[0]._leftPoint).to.equal null
			expect(points[0]._rightPoint).to.equal points[2]

			expect(points[1]._leftPoint).to.equal null
			expect(points[1]._rightPoint).to.equal null

			expect(points[2]._leftPoint).to.equal points[0]
			expect(points[2]._rightPoint).to.equal null

		it "should throw if the point is connected", ->

			pacs = new BezierPacs

			p1 = pacs.createPoint().setTime(0).belongTo(pacs).insert()
			p2 = pacs.createPoint().setTime(100).belongTo(pacs).insert()
			p1.connectToRight()

			(-> p1.remove()).should.throw()

	describe "connectToLeft()", ->

		it "should connect the point to the left", ->

			pacs = new BezierPacs
			p1 = pacs.createPoint()
			.belongTo pacs
			.insert()

			p2 = pacs.createPoint()
			.setTime 200
			.belongTo pacs
			.insert()

			p2.connectToLeft()

			p1.isConnectedToRight().should.equal yes
			p2.isConnectedToLeft().should.equal yes

			p1.getRightConnector().should.equal p2.getLeftConnector()

		it "should throw if already connected", ->

			(-> p2.connectToLeft()).should.throw()

		it "should throw if not in sequence", ->

			(-> (new BezierPacs).createPoint().connectToLeft()).should.throw()

		it "should throw if we're the first point in sequence", ->

			pacs = new BezierPacs
			p1 = pacs.createPoint()
			.belongTo pacs
			.insert()

			p2 = pacs.createPoint().setTime(100).belongTo(pacs).insert()

			(-> p1.connectToLeft()).should.throw()

	describe "connectToRight()", ->

		it "should throw if we're the last point in sequence", ->

			pacs = new BezierPacs
			p1 = pacs.createPoint()
			.belongTo pacs
			.insert()

			p2 = pacs.createPoint().setTime(100).belongTo(pacs).insert()

			(-> p2.connectToRight()).should.throw()

		it "should just call right point's connectToLeft()", ->

			pacs = new BezierPacs
			p1 = pacs.createPoint()
			.belongTo pacs
			.insert()

			p2 = pacs.createPoint()
			.setTime 200
			.belongTo pacs
			.insert()

			p1.connectToRight()

			p1.isConnectedToRight().should.equal yes
			p2.isConnectedToLeft().should.equal yes

			p1.getRightConnector().should.equal p2.getLeftConnector()

	describe "disconnectFromLeft()", ->

		it "should remove connection to the left", ->

			pacs = new BezierPacs
			p1 = pacs.createPoint()
			.belongTo pacs
			.insert()

			p2 = pacs.createPoint()
			.setTime 200
			.belongTo pacs
			.insert()

			p2.connectToLeft()
			p2.disconnectFromLeft()

			p2.isConnectedToLeft().should.equal no
			p1.isConnectedToRight().should.equal no

		it "should throw if we're not connected", ->

			pacs = new BezierPacs
			p1 = pacs.createPoint()
			.belongTo pacs
			.insert()

			p2 = pacs.createPoint()
			.setTime 200
			.belongTo pacs
			.insert()

			(-> p2.disconnectFromLeft()).should.throw()

	describe "disconnectFromRight()", ->

		it "should just call right point's disconnectFromLeft()", ->

			pacs = new BezierPacs
			p1 = pacs.createPoint()
			.belongTo pacs
			.insert()

			p2 = pacs.createPoint()
			.setTime 200
			.belongTo pacs
			.insert()

			p2.connectToLeft()
			p1.disconnectFromRight()

			p2.isConnectedToLeft().should.equal no
			p1.isConnectedToRight().should.equal no

		it "should throw if not connected to right", ->

			pacs = new BezierPacs
			p1 = pacs.createPoint()
			.belongTo pacs
			.insert()

			p2 = pacs.createPoint()
			.setTime 200
			.belongTo pacs
			.insert()

			(-> p1.disconnectFromRight()).should.throw()

	describe "setTime()", ->

		it "should set the point's time", ->

			p = (new BezierPacs).createPoint()

			(-> p.getTime()).should.change.to(200).when -> p.setTime 200

			# p.getTime().should.equal 200

		it "should emit 'time-change'", ->

			p = (new BezierPacs).createPoint()

			p.events.on 'time-change', spy = sinon.spy()

			p.setTime 200

			spy.should.have.been.calledOnce
			spy.should.have.been.calledWith 200

		it "should throw if moving it past its left/right neighbours", ->

			pacs = new BezierPacs

			pacs.createPoint().belongTo(pacs).setTime(100).insert()
			pacs.createPoint().belongTo(pacs).setTime(300).insert()
			p = pacs.createPoint().belongTo(pacs).setTime(200).insert()

			(-> p.setTime(301)).should.throw()

		it "should not throw if moving it past its left/right neighbours after removing it out of sequence", ->

			pacs = new BezierPacs

			pacs.createPoint().belongTo(pacs).setTime(100).insert()
			pacs.createPoint().belongTo(pacs).setTime(300).insert()
			p = pacs.createPoint().belongTo(pacs).setTime(200).insert()

			p.remove()

			(-> p.setTime(301)).should.not.throw()

		it.skip "should report change"

	describe "isEventuallyConnectedTo()", ->

		it "should work", ->

			pacs = new BezierPacs

			p1 = pacs.createPoint()
			.setTime 100
			.belongTo pacs
			.insert()

			p2 = pacs.createPoint()
			.setTime 200
			.belongTo pacs
			.insert()

			p3 = pacs.createPoint()
			.setTime 300
			.belongTo pacs
			.insert()

			p4 = pacs.createPoint()
			.setTime 400
			.belongTo pacs
			.insert()

			p1.connectToRight()
			p2.connectToRight()

			p1.isEventuallyConnectedTo(p3).should.equal yes
			p3.isEventuallyConnectedTo(p1).should.equal yes
			p1.isEventuallyConnectedTo(p2).should.equal yes
			p2.isEventuallyConnectedTo(p1).should.equal yes

			p1.isEventuallyConnectedTo(p4).should.equal no
			p2.isEventuallyConnectedTo(p4).should.equal no
			p3.isEventuallyConnectedTo(p4).should.equal no