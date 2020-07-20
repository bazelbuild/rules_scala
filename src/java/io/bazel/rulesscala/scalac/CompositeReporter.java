package io.bazel.rulesscala.scalac;

import scala.reflect.internal.ReporterImpl;
import scala.tools.nsc.reporters.Reporter;
import scala.reflect.internal.util.Position;

import java.util.List;


class CompositeReporter extends Reporter {

    private final Reporter[] reporters;

    public CompositeReporter(Reporter[] reporters) {
        this.reporters = reporters;
    }

    @Override
    public void info0(Position pos, String msg, Object severity, boolean force) {
        if(severity.equals(INFO()))
            for(Reporter reporter: reporters)
                reporter.info(pos, msg, force);
        else if(severity.equals(WARNING()))
            for(Reporter reporter: reporters)
                reporter.warning(pos, msg);
        else if(severity.equals(ERROR()))
            for(Reporter reporter: reporters)
                reporter.error(pos, msg);


    }

    @Override
    public void resetCount(Object severity){}

    @Override
    public int count(Object severity){
        return 0;
    }

    public Reporter[] getReporters() {
        return reporters;
    }
}