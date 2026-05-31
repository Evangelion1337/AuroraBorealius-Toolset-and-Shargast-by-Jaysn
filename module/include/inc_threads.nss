//:://////////////////////////////////////////////
//:: Thread include
//:: inc_threads
//:://////////////////////////////////////////////
/** @file
    A simple set of functions for creating,
    controlling and destroying threads that
    repeatedly run a given script.
    A thread is implemented as a pseudo-hb that
    executes a given script on each of it's
    beats.

    Threads may be in one of 3 states:
     THREAD_STATE_DEAD:
      Equivalent to the thread not existing at
      all.

     THREAD_STATE_RUNNING:
      The thread is alive, and will execute it's
      script on each of the underlying pseudo-hb's
      beats.

     THREAD_STATE_SLEEPING:
      The thread is alive, but will not execute
      it's script on the pseudo-hb's beats.


    The thread's script will be ExecuteScripted on
    the object that the thread is running on. This
    is the same object that also stores the
    thread's state (all of 3 local variables).


    @author Ornedan
    @date   Created - 14.03.2005
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/* Constant declarations                        */
//////////////////////////////////////////////////

// Thread state constants

/// Thread state - Dead or non-existent
const int THREAD_STATE_DEAD     = 0;
/// Thread state - Running at the moment
const int THREAD_STATE_RUNNING  = 1;
/// Thread state - Sleeping
const int THREAD_STATE_SLEEPING = 2;


// Internal constants. Nothing to see here. <.<  >.>

const string PREFIX           = "prc_thread_";
const string SUFFIX_SCRIPT    = "_script";
const string SUFFIX_INTERVAL  = "_interval";
const string SUFFIX_ITERATION = "_iteration";
const string CUR_THREAD       = "current_thread";


//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Creates a new thread.
 *
 * @param sName                Name of thread to create. Must be non-empty
 * @param sScript              Name of script to run. Must be non-empty
 * @param fExecutionInterval   Amount of time that passes between executions of sScript.
 *                             Only values > 0.0 allowed
 * @param oToRunOn             Object that stores the thread state values, and that
 *                             sScript will be ExecuteScripted on.
 *                             If this is OBJECT_INVALID, the module will be used to hold
 *                             the thread
 *
 * @return                     TRUE if the thread creation was successfull. Possible reasons of failure:
 *                              - One or more parameters were invalid
 *                              - A thread by the given name was already running on oToRunOn
 */
int SpawnNewThread(string sName, string sScript, float fExecutionInterval = 6.0f, object oToRunOn = OBJECT_INVALID);

/**
 * Inspects the state of the given thread.
 *
 * @param sName      Name of thread to inspect. Must be non-empty
 * @param oRunningOn Object that the thread is running on. If this
 *                   is OBJECT_INVALID, the module will be used.
 *
 * @return           One of the THREAD_STATE_* constants. Inspecting a non-
 *                   existent thread, or thread that was running on an object that
 *                   was destroyed will return THREAD_STATE_DEAD
 */
int GetThreadState(string sName, object oRunningOn = OBJECT_INVALID);

/**
 * Gets the name of the script the given thread is running.
 *
 * @param sName      Name of thread to inspect. Must be non-empty
 * @param oRunningOn Object that the thread is running on. If this
 *                   is OBJECT_INVALID, the module will be used.
 *
 * @return           The name of the the given thread executes on success, ""
 *                   on failure (querying with invalid parameters, or on a dead thread)
 */
string GetThreadScript(string sName, object oRunningOn = OBJECT_INVALID);

/** Gets the execution interval for the given thread
 *
 * @param sName      Name of thread to inspect. Must be non-empty
 * @param oRunningOn Object that the thread is running on. If this
 *                   is OBJECT_INVALID, the module will be used.
 *
 * @return           The time between the given thread executing it's script.
 *                   On failure, 0.0f is returned.
 */
float GetThreadExecutionInterval(string sName, object oRunningOn = OBJECT_INVALID);

/**
 * Gets the name of the thread whose script is currently being executed.
 *
 * @return The name of the thread being executed at the time of the call,
 *         or "" if no thread is being executed when this is called.
 */
string GetCurrentThread();

/**
 * Gets the object currently running thread is executing on
 *
 * @return The object the currently executing thread is being executed on
 *         or OBJECT_INVALID if no thread is being executed when this is called.
 */
object GetCurrentThreadObject();

/**
 * Stops further execution of the given thread and removes it's data
 * from the object it was running on.
 *
 * @param sName      Name of thread to terminate. Must be non-empty
 * @param oRunningOn Object that the thread is running on. If this
 *                   is OBJECT_INVALID, the module will be used.
 */
void TerminateThread(string sName, object oRunningOn = OBJECT_INVALID);

/**
 * Stops further execution of the thread currently being executed.
 * A convenience wrapper for TerminateThread to be called from a
 * threadscript.
 */
void TerminateCurrentThread();

/**
 * Sets the stae of the given thread to sleeping.
 *
 * @param sName      Name of thread to set sleeping. Must be non-empty
 * @param oRunningOn Object that the thread is running on. If this
 *                   is OBJECT_INVALID, the module will be used.
 *
 * @return           Whether the operation was successfull. Failure indicates
 *                   that the thread was dead.
 */
int SleepThread(string sName, object oRunningOn = OBJECT_INVALID);

/**
 * Awakens the given thread.
 *
 * @param sName      Name of thread to set back running. Must be non-empty
 * @param oRunningOn Object that the thread is running on. If this
 *                   is OBJECT_INVALID, the module will be used.
 *
 * @return           Whether the operation was successfull. Failure indicates
 *                   that the thread was dead.
 */
int AwakenThread(string sName, object oRunningOn = OBJECT_INVALID);

/**
 * Changes the execution interval of the given thread.
 *
 * @param sName        Name of thread to set back running. Must be non-empty
 * @param oRunningOn   Object that the thread is running on. If this
 *                     is OBJECT_INVALID, the module will be used.
 * @param fNewInterval The amount of time between executions of the
 *                     threadscript that will used from next execution
 *                     onwards.
 *
 * @return             Returns whether the operation was successfull. Failure indicates
 *                     that the thread was dead.
 */
int ChangeExecutionInterval(string sName, float fNewInterval, object oRunningOn = OBJECT_INVALID);

/*
 * Internal function. This is the pseudo-hb function that calls itself.
 *
 * @param sName        name of the thread to run. Used to build local variable names
 * @param oRunningOn   object that stores the variables, and the one that will
 *                     be passed to ExecuteScript
 */
void RunThread(string sName, object oRunningOn, int iIteration);


//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////


int SpawnNewThread(string sName, string sScript, float fExecutionInterval = 6.0f, object oToRunOn = OBJECT_INVALID){
    if(oToRunOn == OBJECT_INVALID)
    	oToRunOn = GetModule();

    // Check paramaeters for correctness
    if(sName   == ""              ||
       sScript == ""              ||
       fExecutionInterval <= 0.0f ||
       !GetIsObjectValid(oToRunOn))
        return FALSE;

    // Make sure there is no thread by this name already running
    //    if(GetLocalInt(oToRunOn, PREFIX + sName))
    //    return FALSE;
    // use iterations in place of the above to make it more reliable in case of a PC thread timing out while not logged in
    int iIteration = GetLocalInt(oToRunOn, PREFIX + sName + SUFFIX_ITERATION);

    // Set the thread variables
    SetLocalInt(oToRunOn,    PREFIX + sName, THREAD_STATE_RUNNING);
    SetLocalString(oToRunOn, PREFIX + sName + SUFFIX_SCRIPT, sScript);
    SetLocalFloat(oToRunOn,  PREFIX + sName + SUFFIX_INTERVAL, fExecutionInterval);

    // Start thread execution
    DelayCommand(fExecutionInterval, RunThread(sName, oToRunOn, iIteration));

    // All done successfully
    return TRUE;
}


int GetThreadState(string sName, object oRunningOn = OBJECT_INVALID){
    if(oRunningOn == OBJECT_INVALID)
        oRunningOn = GetModule();

    // Check paramaeters for correctness
    if(sName == "" ||
       !GetIsObjectValid(oRunningOn))
        return FALSE;

    // Return the local determining if the thread exists
    return GetLocalInt(oRunningOn, PREFIX + sName);
}


string GetThreadScript(string sName, object oRunningOn = OBJECT_INVALID){
    if(oRunningOn == OBJECT_INVALID)
        oRunningOn = GetModule();

    // Check paramaeters for correctness
    if(sName == "" ||
       !GetIsObjectValid(oRunningOn))
        return "";

    return GetLocalString(oRunningOn, PREFIX + sName + SUFFIX_SCRIPT);
}


float GetThreadExecutionInterval(string sName, object oRunningOn = OBJECT_INVALID){
    if(oRunningOn == OBJECT_INVALID)
        oRunningOn = GetModule();

    // Check paramaeters for correctness
    if(sName == "" ||
       !GetIsObjectValid(oRunningOn))
        return 0.0f;

    return GetLocalFloat(oRunningOn, PREFIX + sName + SUFFIX_INTERVAL);
}


string GetCurrentThread(){
    return GetLocalString(GetModule(), PREFIX + CUR_THREAD);
}


object GetCurrentThreadObject(){
    return GetIsObjectValid(GetLocalObject(GetModule(), PREFIX + CUR_THREAD)) ?
            GetLocalObject(GetModule(), PREFIX + CUR_THREAD) :
            OBJECT_INVALID;
}


void TerminateThread(string sName, object oRunningOn = OBJECT_INVALID){
    if(oRunningOn == OBJECT_INVALID)
        oRunningOn = GetModule();

    // Check paramaeters for correctness. Just an optimization here, since
    // if either of these were not valid, nothing would happen.
    if(sName == "" ||
       !GetIsObjectValid(oRunningOn))
        return;

    // Remove the thread variables
    DeleteLocalInt(oRunningOn,    PREFIX + sName);
    DeleteLocalString(oRunningOn, PREFIX + sName + SUFFIX_SCRIPT);
    DeleteLocalFloat(oRunningOn,  PREFIX + sName + SUFFIX_INTERVAL);

    // Increase the iteration so that any lingering runthread fail to fire if the thread is restarted
    int iExpectedIteration = GetLocalInt(oRunningOn, PREFIX + sName + SUFFIX_ITERATION);
    iExpectedIteration++;
    SetLocalInt(oRunningOn, PREFIX + sName + SUFFIX_ITERATION, iExpectedIteration);
}


void TerminateCurrentThread(){
    TerminateThread(GetLocalString(GetModule(), PREFIX + CUR_THREAD),
                    GetLocalObject(GetModule(), PREFIX + CUR_THREAD)
    );
}


int SleepThread(string sName, object oRunningOn = OBJECT_INVALID){
    if(oRunningOn == OBJECT_INVALID)
        oRunningOn = GetModule();

    // Check paramaeters for correctness
    if(sName == "" ||
       !GetIsObjectValid(oRunningOn))
        return FALSE;

    // Change thread state
    SetLocalInt(oRunningOn, PREFIX + sName, THREAD_STATE_SLEEPING);

    return TRUE;
}


int AwakenThread(string sName, object oRunningOn = OBJECT_INVALID){
    if(oRunningOn == OBJECT_INVALID)
        oRunningOn = GetModule();

    // Check paramaeters for correctness
    if(sName == "" ||
       !GetIsObjectValid(oRunningOn))
        return FALSE;

    // Change thread state
    SetLocalInt(oRunningOn, PREFIX + sName, THREAD_STATE_RUNNING);

    return TRUE;
}


int ChangeExecutionInterval(string sName, float fNewInterval, object oRunningOn = OBJECT_INVALID){
    if(oRunningOn == OBJECT_INVALID)
        oRunningOn = GetModule();

    // Check paramaeters for correctness
    if(!GetThreadState(sName, oRunningOn) ||
       fNewInterval <= 0.0f)
        return FALSE;


    SetLocalFloat(oRunningOn, PREFIX + sName + SUFFIX_INTERVAL, fNewInterval);
    return TRUE;
}


void RunThread(string sName, object oRunningOn, int iIteration){
    // Abort if we're on the wrong iteration, this allows us to
    // be liberal about spawning threads in case they've timed
    // out while a PC was logged out
    int iExpectedIteration = GetLocalInt(oRunningOn, PREFIX + sName + SUFFIX_ITERATION);
    if(iIteration != iExpectedIteration)
        return;
    iExpectedIteration++;
    SetLocalInt(oRunningOn, PREFIX + sName + SUFFIX_ITERATION, iExpectedIteration);

    // Abort if the object we're running on has ceased to exist
    // or if the thread has been terminated
    int nThreadState = GetThreadState(sName, oRunningOn);
    if(nThreadState == THREAD_STATE_DEAD)
        return;

    // Mark this thread as running
    SetLocalString(GetModule(), PREFIX + CUR_THREAD, sName);
    SetLocalObject(GetModule(), PREFIX + CUR_THREAD, oRunningOn);

    // Execute the threadscript if the thread is running atm
    if(nThreadState == THREAD_STATE_RUNNING){
        string sScript = GetLocalString(oRunningOn, PREFIX + sName + SUFFIX_SCRIPT);
        ExecuteScript(sScript, oRunningOn);
    }

    // Schedule next execution, unless we've been terminated
    if(GetThreadState(sName, oRunningOn) != THREAD_STATE_DEAD){
        DelayCommand(GetLocalFloat(oRunningOn, PREFIX + sName + SUFFIX_INTERVAL), RunThread(sName, oRunningOn, iExpectedIteration));
    }

    // Clean up the module variables
    DeleteLocalString(GetModule(), PREFIX + CUR_THREAD);
    DeleteLocalObject(GetModule(), PREFIX + CUR_THREAD);
}


// Test main
//void main(){}
