import cpu.iss.riscv
import memory.memory
import vp.clock_domain
import interco.router
import utils.loader.loader
import gvsoc.systree
import gvsoc.runner
import gdbserver.gdbserver
import global_mem


GAPY_TARGET = True

# Number of cores in the SoC. global_mem.cpp has one counter per core, so this
# can't go above 16 without growing it.
NB_CORES = 16

class Soc(gvsoc.systree.Component):

    def __init__(self, parent, name, parser):
        super().__init__(parent, name)

        # Parse the arguments to get the path to the binary to be loaded
        [args, __] = parser.parse_known_args()

        binary = args.binary

        # Main interconnect
        ico = interco.router.Router(self, 'ico')

        # Main memory
        mem = memory.memory.Memory(self, 'mem', size=0x00100000)
        ico.o_MAP(mem.i_INPUT(), 'mem', base=0x00000000, size=0x00100000, rm_base=True)

        # Global memory shared by all the cores: sync register at offset 0,
        # then one counter per core
        global_memory = global_mem.Global_Mem(self, 'global_mem')
        ico.o_MAP(global_memory.i_INPUT(), 'global_mem', base=0x20000000, size=0x00001000, rm_base=True)

        # Instantiates the cores and connect fetch and data to the interconnect.
        # Core 0 keeps the name 'host', the plot scripts trace 'host/insn'.
        cores = []
        for core_id in range(NB_CORES):
            name = 'host' if core_id == 0 else 'core%d' % core_id
            core = cpu.iss.riscv.Riscv(self, name, isa='rv64imafdc', core_id = core_id)
            core.o_FETCH     ( ico.i_INPUT     ())
            core.o_DATA      ( ico.i_INPUT     ())
            core.o_DATA_DEBUG(ico.i_INPUT    ())
            cores.append(core)


        # Finally connect an ELF loader, which will execute first and will then
        # send to every core the boot address and notify them they can start
        loader = utils.loader.loader.ElfLoader(self, 'loader', binary=binary)
        loader.o_OUT     ( ico.i_INPUT     ())
        for core in cores:
            loader.o_START   ( core.i_FETCHEN  ())
            loader.o_ENTRY   ( core.i_ENTRY    ())


        gdbserver.gdbserver.Gdbserver(self, 'gdbserver')



# This is a wrapping component of the real one in order to connect a clock generator to it
# so that it automatically propagate to other components
class Rv64(gvsoc.systree.Component):

    def __init__(self, parent, name, parser, options):

        super().__init__(parent, name, options=options)

        clock = vp.clock_domain.Clock_domain(self, 'clock', frequency=100000000)
        soc = Soc(self, 'soc', parser)
        clock.o_CLOCK    ( soc.i_CLOCK     ())




# This is the top target that gapy will instantiate
class Target(gvsoc.runner.Target):

    def __init__(self, parser, options):
        super(Target, self).__init__(parser, options,
            model=Rv64, description="RV64 virtual board")

