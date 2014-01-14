async = require 'async'

Cache = require 'cache-storage'
MemoryStorage = require 'cache-storage/Storage/MemoryAsyncStorage'

cache = null

describe 'MemoryAsyncStorage', ->

	beforeEach( ->
		cache = new Cache(new MemoryStorage, 'test')
	)

	describe 'saving/loading', ->

		it 'should save true and load it', (done) ->
			cache.save 'true', true, ->
				cache.load 'true', (data) ->
					expect(data).to.be.true
					done()

		it 'should return null if item not exists', (done) ->
			cache.load 'true', (data) ->
				expect(data).to.be.null
				done()

		it 'should save true and delete it', (done) ->
			cache.save 'true', true, ->
				cache.remove 'true', ->
					cache.load 'true', (data) ->
						expect(data).to.be.null
						done()

		it 'should save true to cache from fallback function in load', (done) ->
			cache.load 'true', ->
				return true
			, (data) ->
				expect(data).to.be.true
				done()

	describe 'expiration', ->

		it 'should expire "true" value after file is changed', (done) ->
			cache.save 'true', true, {files: [__filename]}, ->
				setTimeout( ->
					cache.load 'true', (data) ->
						expect(data).to.be.true
						changeFile(__filename)
						cache.load 'true', (data) ->
							expect(data).to.be.null
							done()
				, 100)


		it 'should remove all items with tag "article"', (done) ->
			data = [
				['one', null, ['article']]
				['two', 'two', ['category']]
				['three', null, ['article']]
			]
			async.each(data, (item, cb) ->
				cache.save item[0], item[0], {tags: item[2]}, -> cb()
			, ->
				cache.clean(tags: ['article'], ->
					async.each(data, (item, cb) ->
						cache.load item[0], (data) ->
							expect(data).to.be.equal(item[1])
							cb()
					, ->
						done()
					)
				)
			)

		it 'should expire "true" value after 1 second"', (done) ->
			cache.save 'true', true, {expire: {seconds: 1}}, ->
				setTimeout( ->
					cache.load 'true', (data) ->
						expect(data).to.be.null
						done()
				, 1100)

		it 'should expire "true" value after "first" value expire', (done) ->
			cache.save 'first', 'first', ->
				cache.save 'true', true, {items: ['first']}, ->
					cache.remove 'first', ->
						cache.load 'true', (data) ->
							expect(data).to.be.null
							done()

		it 'should expire all items with priority bellow 50', (done) ->
			cache.save 'one', 'one', {priority: 100}, ->
				cache.save 'two', 'two', {priority: 10}, ->
					cache.clean {priority: 50}, ->
						cache.load 'one', (data) ->
							expect(data).to.be.equal('one')
							cache.load 'two', (data) ->
								expect(data).to.be.null
								done()

		it 'should remove all items from cache', (done) ->
			cache.save 'one', 'one', ->
				cache.save 'two', 'two', ->
					cache.clean 'all', ->
						cache.load 'one', (data) ->
							expect(data).to.be.null
							cache.load 'two', (data) ->
								expect(data).to.be.null
								done()