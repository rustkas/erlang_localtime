REBAR := ./rebar3
REBAR_URL := https://s3.amazonaws.com/rebar3/rebar3
ERL       ?= erl



all: include/tz_index.hrl compile

include/tz_index.hrl: src/ibuild.erl include/tz_database.hrl
	cd include && cp ../src/ibuild.erl ibuild.erl && escript ibuild.erl; EV=$$?; rm ibuild.erl; exit $$EV
	
compile: $(REBAR)
	$(REBAR) compile

check: $(REBAR)
	$(REBAR) eunit


clean: $(REBAR) clean_doc
	$(REBAR) clean

clean_doc:
	@rm -f doc/*.html
	@rm -f doc/erlang.png
	@rm -f doc/edoc-info	

xref: $(REBAR)
	$(REBAR) as test xref

dialyzer: $(REBAR)
	$(REBAR) as check dialyzer
	
doc:  $(REBAR) doc/overview.edoc
	$(REBAR) edoc

doc_private: $(REBAR)
	$(REBAR) as doc_private edoc	


./rebar3:
	$(ERL) -noshell -s inets -s ssl \
	  -eval '{ok, saved_to_file} = httpc:request(get, {"$(REBAR_URL)", []}, [], [{stream, "./rebar3"}])' \
	  -s init stop
	chmod +x ./rebar3