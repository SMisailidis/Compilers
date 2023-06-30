default: agent
	gcc agent.lex.c -o agent -lfl

agent: agentLang.l
	flex -o agent.lex.c agentLang.l



clean:
	rm -f agent
	rm -f agent.lex.c

