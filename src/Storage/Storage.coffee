fs = require 'fs'
moment = require 'moment'
path = require 'path'
Cache = require '../Cache'

class Storage


	cache: null


	read: (key) ->
		throw new Error 'Cache storage: read method is not implemented.'


	write: (key, data, dependencies = {}) ->
		throw new Error 'Cache storage: write method is not implemented.'


	remove: (key) ->
		throw new Error 'Cache storage: remove method is not implemented.'


	clean: (conditions) ->
		throw new Error 'Cache storage: clean method is not implemented'


	getMeta: ->
		throw new Error 'Cache storage: getMeta method is not implemented'


	findMeta: (key) ->
		meta = @getMeta()
		return if typeof meta[key] != 'undefined' then meta[key] else null


	findKeysByTag: (tag) ->
		metas = @getMeta()
		result = []
		for key, meta of metas
			if typeof meta[Cache.TAGS] != 'undefined' && meta[Cache.TAGS].indexOf(tag) != -1
				result.push(key)
		return result


	findKeysByPriority: (priority) ->
		metas = @getMeta()
		result = []
		for key, meta of metas
			if typeof meta[Cache.PRIORITY] != 'undefined' && meta[Cache.PRIORITY] <= priority
				result.push(key)
		return result


	verify: (meta) ->
		typefn = Object.prototype.toString

		if typefn.call(meta) == '[object Object]'
			if typeof meta[Cache.FILES] != 'undefined'
				for file, time of meta[Cache.FILES]
					if (new Date(fs.statSync(file).mtime)).getTime() != time then return false

			if typeof meta[Cache.EXPIRE] != 'undefined'
				if moment().valueOf() >= meta[Cache.EXPIRE] then return false

			if typeof meta[Cache.ITEMS] != 'undefined'
				for item in meta[Cache.ITEMS]
					item = @findMeta(item)
					if (item == null) || (item != null && @verify(item) == false) then return false

		return true


	parseDependencies: (dependencies) ->
		typefn = Object.prototype.toString
		result = {}

		if typefn.call(dependencies) == '[object Object]'
			if typeof dependencies[Cache.FILES] != 'undefined'
				files = {}
				for file in dependencies[Cache.FILES]
					file = path.resolve(file)
					files[file] = (new Date(fs.statSync(file).mtime)).getTime()
				result[Cache.FILES] = files

			if typeof dependencies[Cache.EXPIRE] != 'undefined'
				switch typefn.call(dependencies[Cache.EXPIRE])
					when '[object String]' then time = moment(dependencies[Cache.EXPIRE], Cache.TIME_FORMAT)
					when '[object Object]' then time = moment().add(dependencies[Cache.EXPIRE])
					else throw new Error 'Expire format is not valid'
				result[Cache.EXPIRE] = time.valueOf()

			if typeof dependencies[Cache.ITEMS] != 'undefined'
				result[Cache.ITEMS] = []
				for item, i in dependencies[Cache.ITEMS]
					result[Cache.ITEMS].push(@generateKey(item))

			if typeof dependencies[Cache.PRIORITY] != 'undefined' then result[Cache.PRIORITY] = dependencies[Cache.PRIORITY]

			if typeof dependencies[Cache.TAGS] != 'undefined' then result[Cache.TAGS] = dependencies[Cache.TAGS]

		return result


module.exports = Storage
