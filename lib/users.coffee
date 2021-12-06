if Meteor.isClient
    Router.route '/users', -> @render 'users'

    Template.users.onCreated ->
        @autorun -> Meteor.subscribe('users')
        # @autorun => Meteor.subscribe 'user_search', Session.get('username_query')
    Template.users.helpers
        user_docs: ->
            username_query = Session.get('username_query')
            if username_query
                Meteor.users.find({
                    username: {$regex:"#{username_query}", $options: 'i'}
                    # roles:$in:['resident','owner']
                    },{ limit:parseInt(Session.get('view_limit')) }).fetch()
            else
                Meteor.users.find({
                    },{ limit:parseInt(Session.get('view_limit')) }).fetch()

    Template.users.events
        'click .add_user': ->
            new_username = prompt('username')
            Meteor.call 'add_user', new_username, (err,res)->
                # console.log res
                new_user = Meteor.users.findOne res
                Router.go "/user/#{new_user.username}"
        'keyup .username_search': (e,t)->
            username_query = $('.username_search').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                Session.set 'username_query',username_query




if Meteor.isServer
    Meteor.publish 'users', (limit)->
        match = {membership_group_ids:$in:[Meteor.user().current_group_id]}
        # match.station = $exists:true
        limit = if limit then limit else 20
        Meteor.users.find(match,limit:limit)


    Meteor.publish 'user_search', (username, role)->
        if role
            if username
                Meteor.users.find({
                    username: {$regex:"#{username}", $options: 'i'}
                    # roles:$in:[role]
                },{ limit:20})
            else
                Meteor.users.find({
                    # roles:$in:[role]
                },{ limit:20})
        else
            if username
                Meteor.users.find({
                    username: {$regex:"#{username}", $options: 'i'}
                    # roles:$in:[role]
                },{ limit:20})
            else
                Meteor.users.find({
                    # roles:$in:[role]
                },{ limit:20})
            Meteor.users.find({
                username: {$regex:"#{username}", $options: 'i'}
            },{ limit:20})