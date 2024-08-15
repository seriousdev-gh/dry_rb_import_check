module MyModule
    class MyClass
        attr_reader :qaz

        include Import[
            'service.user_login_required',
            'service.user_login',
            'logger.warning',
            foo: 'bar',
            test: 'test1'
        ]

        def call
            user_login.call('foobar')
            test foo
        end

        def test(asd)
            asd
        end
    end

    class B
        class C
            include Import[
                'service1',
                'service2'
            ]
        end
    end
end

module A

end

# s(:module,
#   s(:const, nil, :MyModule),
#   s(:class,
#     s(:const, nil, :MyClass), nil,
#     s(:begin,
#       s(:send, nil, :include,
#         s(:send,
#           s(:const, nil, :Import), :[],
#           s(:str, "service.user_login_required"),
#           s(:str, "service.user_login"),
#           s(:str, "logger.warning"))),
#       s(:def, :call,
#         s(:args),
#         s(:send,
#           s(:send, nil, :user_login), :call,
#           s(:str, "foobar"))))))