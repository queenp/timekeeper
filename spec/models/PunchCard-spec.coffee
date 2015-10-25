sinon       = require 'sinon'
Pause = require '../../lib/models/Pause.js'
moment = require 'moment'

PunchCard = require '../../lib/models/PunchCard.js'

mockCardWithPauses = =>
    return new PunchCard({
        label: "jeje",
        start:0,
        end:10000,
        pauses: [
            {
                start:1234,
                end:2345,
                duration:(2345-1234)
            }
        ],
        autoPauses: [
            {
                start:2346,
                end:3456,
                duration:3456-2346
            }
        ]
    });

describe "PunchCard started from defaults", ->

    beforeEach ->
        @clock = sinon.useFakeTimers();
        @card = new PunchCard({label:"MyProject"})

    afterEach ->
        @clock.restore()

    it "has no this.end value to start with", ->
        expect(@card.end).toBeUndefined()

    it "has a duration", ->
        @card.start = Date.now()
        @clock.tick(40)
        expect(@card.duration.asMilliseconds()).toEqual(40)

    it "can be initialised with a label", ->
        mock = new PunchCard({label:'myLabel'})
        expect(mock.label).toEqual('myLabel')

    it "can be initialised with a start Timestamp", ->
        stamp = Date.now()
        mock = new PunchCard({start:stamp, end:stamp+5000})
        expect(+mock.start).toEqual(stamp)
        expect(+mock.end).toEqual(stamp+5000)
        expect(mock.duration.asMilliseconds()).toEqual(5000)

    it "can be initialised with pauses from JSON", ->
        mock = mockCardWithPauses()
        # expect(mock.pauses[0].start).to.equal(1234)
        # expect(mock.pauses[0].end).to.equal(2345)
        # expect(mock.pauses[0].duration).to.equal(1111)
        expect(mock.duration.asMilliseconds()).toEqual(10000 - mock.pauses[0].duration - mock.autoPauses[0].duration)

    it "can be exported out to object notation", ->
        mock = mockCardWithPauses()
        newObject = mock.object
        expect(newObject.start).toEqual(0)
        expect(newObject.end).toEqual(10000)
        expect(newObject.pauses[0].start).toEqual(1234)

    it "says when it isPaused", ->
        expect(@card.isPaused).toBe.false

    it "can also be paused", ->
        @card.pause(Date.now())
        expect(@card.isPaused).toBe.true

    it "fails to pause when already paused", ->
        @card.pause(Date.now())
        expect(@card.pause(Date.now())).toBe.false

    it "resumes from a pause", ->
        startPauses = @card.pauses.length
        @card.pause(Date.now())
        @clock.tick(2345)
        @card.resume(Date.now())
        expect(@card.pauses.length).toEqual(startPauses + 1)

    it "can also be autoPaused", ->
        @card.autoPause()
        expect(@card.isPaused).toBe.true

    it "fails to autoPause when already paused", ->
        @card.pause(Date.now())
        expect(@card.autoPause()).toBe.false

    it "resumes from an autoPause", ->
        count = @card.autoPauses.length
        @card.autoPause()
        @clock.tick(5000 * Math.random())
        @card.resume(Date.now())
        expect(@card.autoPauses.length).toEqual(count + 1)