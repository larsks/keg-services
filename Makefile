%.svg: %.dot
	dot -T svg -o $@ $<

all: components.svg
